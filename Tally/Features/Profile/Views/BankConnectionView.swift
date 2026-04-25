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

    private enum PlaidLoadingBusyState {
        case idle
        case preparingLink
        case importingTransactions
    }

    @SwiftUI.Environment(\.dismiss) private var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel
    var onImportCompleted: (Int) -> Void = { _ in }
    private let api = PlaidBackendClient()
    @State private var handler: Handler?
    @State private var busy = false
    @State private var loadingState: PlaidLoadingBusyState = .idle
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
                        if busy && loadingState == .preparingLink {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text("Plaid is loading...")
                                    .font(.urbanist(.bold, size: 17))
                                    .foregroundStyle(.white)
                            }
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
            .overlay {
                if busy && loadingState == .importingTransactions {
                    ZStack {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        VStack(spacing: 10) {
                            ProgressView()
                                .tint(Color.primaryBlue)
                                .scaleEffect(1.1)
                            Text("Importing transactions from Plaid...")
                                .font(.manrope(.bold, size: 15))
                                .foregroundStyle(Color.heading)
                            Text("This may take some time.")
                                .font(.manrope(.regular, size: 13))
                                .foregroundStyle(Color.mutedText)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
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
        loadingState = .preparingLink
        error = nil
        defer {
            if loadingState == .preparingLink {
                busy = false
                loadingState = .idle
            }
        }

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
        loadingState = .importingTransactions
        defer {
            busy = false
            loadingState = .idle
        }
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                error = "Not signed in."
                return
            }
            let itemID = try await api.exchangePublicToken(
                publicToken: publicToken,
                clientUserId: uid
            )
            try await profileViewModel.saveLinkedBank(itemID: itemID, institutionName: institutionName)
            let synced = try await api.syncTransactions(clientUserId: uid)
            try await profileViewModel.savePlaidTransactions(synced)
            onImportCompleted(profileViewModel.importedPlaidTransactionCount)
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
