//
//  RMAPIClient.swift
//  rmProApp
//

import Foundation

final class RMAPIClient {
    static let shared = RMAPIClient()

    private let baseURL = URL(string: "https://trieq.api.rentmanager.com/")!
    private let session: URLSession
    private let coalescer = RequestCoalescer()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<R: RMRequest>(_ request: R) async throws -> R.Response {
        let urlRequest = try await makeURLRequest(for: request)
        let cacheKey = urlRequest.url?.absoluteString ?? UUID().uuidString

        let data = try await coalescer.run(key: cacheKey) { [session] in
            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await session.data(for: urlRequest)
            } catch let error as URLError {
                throw RMAPIError.transport(error)
            }

            guard let http = response as? HTTPURLResponse else {
                throw RMAPIError.invalidResponse
            }

            guard (200...299).contains(http.statusCode) else {
                throw RMAPIError.fromStatus(http.statusCode, data: data)
            }

            return data
        }

        do {
            return try decoder.decode(R.Response.self, from: data)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw RMAPIError.decoding(error, rawBody: raw)
        }
    }

    private func makeURLRequest<R: RMRequest>(for request: R) async throws -> URLRequest {
        guard let token = await TokenManager.shared.token else {
            throw RMAPIError.missingToken
        }

        var components = URLComponents(url: baseURL.appendingPathComponent(request.path), resolvingAgainstBaseURL: false)
        if !request.queryItems.isEmpty {
            components?.queryItems = request.queryItems
        }

        guard let url = components?.url else {
            throw RMAPIError.invalidResponse
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue(token, forHTTPHeaderField: "X-RM12Api-ApiToken")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = request.body {
            urlRequest.httpBody = body
        }
        return urlRequest
    }
}
