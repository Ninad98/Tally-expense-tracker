//
//  BankConnectionView.swift
//  Tally
//
//  Created by Mazen Tarek on 4/19/26.
//

import SwiftUI
import LinkKit
import FirebaseAuth
import UIKit

@MainActor
struct BankConnectionView: View {

    @SwiftUI.Environment(\.dismiss) private var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel
    private let api = PlaidBackendClient()
    @State private var handler: Handler?
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Link your bank to bring transactions into Tally.")
                    .font(.manrope(.medium, size: 15))
                    .foregroundStyle(Color.bodyText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    Task { await openPlaid() }
                } label: {
                    ZStack {
                        if busy {
                            ProgressView().tint(.white)
                        } else {
                            Text("Connect with Plaid")
                                .font(.urbanist(.bold, size: 17))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .disabled(busy)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pageBG)
            .navigationTitle("Connect bank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                        .font(.manrope(.medium, size: 16))
                        .foregroundStyle(Color.primaryBlue)
                }
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK", role: .cancel) { error = nil }
        } message: {
            Text(error ?? "")
        }
    }

    // Attribution: https://plaid.com/docs/link/ios/ and GenAI.
    private func openPlaid() async {
        guard !busy else { return }
        busy = true
        error = nil
        defer { busy = false }

        do {
            let token = try await api.createLinkToken(clientUserId: Auth.auth().currentUser?.uid)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard token.hasPrefix("link-"), !token.isEmpty else {
                error = "Backend returned an invalid link token."
                return
            }

            var configuration = LinkTokenConfiguration(token: token) { success in
                let institutionName = success.metadata.institution.name
                Task {
                    await exchangeAndFinish(
                        publicToken: success.publicToken,
                        institutionName: institutionName
                    )
                }
            }
            configuration.onExit = { exit in
                Task { @MainActor in handleExit(exit) }
            }
            configuration.onEvent = { event in
                print("Plaid event: \(event.eventName)")
            }

            switch Plaid.create(configuration, onLoad: {}) {
            case .success(let h):
                handler = h
                openLink(with: h)
            case .failure(let creationError):
                error = String(describing: creationError)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func exchangeAndFinish(publicToken: String, institutionName: String?) async {
        busy = true
        defer { busy = false }
        do {
            let itemID = try await api.exchangePublicToken(publicToken: publicToken)
            try await profileViewModel.saveLinkedBank(itemID: itemID, institutionName: institutionName)
            handler = nil
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func handleExit(_ exit: LinkExit) {
        handler = nil
        if let linkError = exit.error {
            error = String(describing: linkError)
        }
    }

    private func openLink(with handler: Handler) {
        guard let presenter = topViewController() else {
            error = "Could not find a view controller to present Plaid Link."
            return
        }
        handler.open(presentUsing: .viewController(presenter))
    }

    @MainActor
    private func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController
        return topViewController(from: root)
    }

    @MainActor
    private func topViewController(from root: UIViewController?) -> UIViewController? {
        if let navigation = root as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(from: presented)
        }
        return root
    }
}

#Preview {
    BankConnectionView(profileViewModel: ProfileViewModel())
}
