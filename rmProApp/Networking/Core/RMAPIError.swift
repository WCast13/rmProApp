//
//  RMAPIError.swift
//  rmProApp
//

import Foundation

enum RMAPIError: Error, LocalizedError {
    case unauthorized
    case forbidden
    case notFound
    case rateLimited(retryAfter: TimeInterval?)
    case server(statusCode: Int, body: String)
    case client(statusCode: Int, body: String)
    case decoding(Error, rawBody: String)
    case transport(URLError)
    case invalidResponse
    case missingToken

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized (401). Token may be invalid or expired."
        case .forbidden:
            return "Forbidden (403)."
        case .notFound:
            return "Not found (404)."
        case .rateLimited(let retryAfter):
            if let retry = retryAfter {
                return "Rate limited (429). Retry after \(Int(retry))s."
            }
            return "Rate limited (429)."
        case .server(let code, let body):
            return "Server error (\(code)): \(body)"
        case .client(let code, let body):
            return "Client error (\(code)): \(body)"
        case .decoding(let error, _):
            return "Decoding failed: \(error.localizedDescription)"
        case .transport(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received a non-HTTP response."
        case .missingToken:
            return "No authentication token available."
        }
    }

    static func fromStatus(_ statusCode: Int, data: Data) -> RMAPIError {
        let body = String(data: data, encoding: .utf8) ?? ""
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 429: return .rateLimited(retryAfter: nil)
        case 500...599: return .server(statusCode: statusCode, body: body)
        default: return .client(statusCode: statusCode, body: body)
        }
    }
}
