//
//  CurrencySelectionViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 3/14/26.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

final class CurrencySelectionViewModel: NSObject, ObservableObject {

    @Published var selectedCurrency: Currency?
    @Published var isDetecting: Bool = false
    @Published var detectionError: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func detectCurrency() {
        detectionError = nil
        switch locationManager.authorizationStatus {
        case .notDetermined:
            isDetecting = true
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isDetecting = true
            locationManager.requestLocation()
        case .denied, .restricted:
            detectionError = "Location access denied. Please enable it in Settings."
        @unknown default:
            break
        }
    }

    private func reverseGeocode(location: CLLocation) {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            isDetecting = false
            detectionError = "Could not detect location. Please select location manually."
            return
        }

        Task { @MainActor in
            do {
                let mapItems = try await request.mapItems
                isDetecting = false
                if let countryCode = mapItems.first?.addressRepresentations?.region?.identifier,
                   let matched = Currency.currency(forCountryCode: countryCode) {
                    selectedCurrency = matched
                } else {
                    detectionError = "Currency not found for your region. Please select manually."
                }
            } catch {
                isDetecting = false
                detectionError = "Location unavailable. Please select location manually."
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CurrencySelectionViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            guard isDetecting else { return }
            manager.requestLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                let wasTrying = self.isDetecting
                self.isDetecting = false
                if wasTrying {
                    self.detectionError = "Location access denied. Please enable it in Settings."
                }
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            isDetecting = false
            return
        }
        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isDetecting = false
            self.detectionError = "Location unavailable. Please select location manually."
        }
    }
}
