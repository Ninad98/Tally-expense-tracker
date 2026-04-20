//
//  PlaidBackendClient.swift
//  Tally
//
//  Created by Mazen Tarek on 4/19/26.
//

import Foundation

final class PlaidBackendClient {

    private struct ErrorBody: Decodable {
        let detail: String?
    }

    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    private static var baseURL: URL {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "PLAID_BACKEND_BASE_URL") as? String,
           let url = URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)),
           url.scheme != nil {
            return url
        }
        return URL(string: "http://127.0.0.1:8000")!
    }

    // Attribution: https://plaid.com/docs/link/ios/ and GenAI.
    func createLinkToken(clientUserId: String?) async throws -> String {
        struct Request: Encodable {
            let clientUserId: String?
            enum CodingKeys: String, CodingKey { case clientUserId = "client_user_id" }
        }
        struct Response: Decodable {
            let linkToken: String
            enum CodingKeys: String, CodingKey { case linkToken = "link_token" }
        }
        let url = Self.baseURL.appendingPathComponent("api/create_link_token")
        let response = try await post(
            url: url,
            body: Request(clientUserId: clientUserId),
            responseType: Response.self
        )
        return response.linkToken
    }

    // Attribution: https://plaid.com/docs/link/ios/ and GenAI.
    func exchangePublicToken(publicToken: String) async throws {
        struct Request: Encodable {
            let publicToken: String
            enum CodingKeys: String, CodingKey { case publicToken = "public_token" }
        }
        struct Response: Decodable {
            let accessToken: String
            let itemID: String
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case itemID = "item_id"
            }
        }
        let url = Self.baseURL.appendingPathComponent("api/exchange_public_token")
        let response = try await post(
            url: url,
            body: Request(publicToken: publicToken),
            responseType: Response.self
        )
        _ = response
    }

    private func post<Req: Encodable, Res: Decodable>(
        url: URL,
        body: Req,
        responseType: Res.Type
    ) async throws -> Res {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw Self.httpError("No HTTP response.")
        }
        guard (200 ... 299).contains(http.statusCode) else {
            if let decoded = try? decoder.decode(ErrorBody.self, from: data),
               let detail = decoded.detail, !detail.isEmpty {
                throw Self.httpError(detail)
            }
            throw Self.httpError("Server error (\(http.statusCode)).")
        }
        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            throw Self.httpError("Could not read Plaid backend response.")
        }
    }

    private static func httpError(_ message: String) -> Error {
        NSError(domain: "PlaidBackend", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
