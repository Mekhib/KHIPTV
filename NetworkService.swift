import Foundation

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided was invalid."
        case .invalidResponse: return "The server returned an invalid response."
        case .httpError(let code): return "HTTP Error: \(code)"
        case .decodingError(let error): return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}

// MARK: - Generic API Client

actor APIClient {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        // Give the provider time to compile massive JSON payloads
        config.timeoutIntervalForRequest = 90
        config.timeoutIntervalForResource = 300
        
        // Optimize cache policy for tvOS
        config.requestCachePolicy = .useProtocolCachePolicy
        
        self.session = URLSession(configuration: config)
    }
    
    /// Fetches and decodes any JSON payload into the specified generic Decodable type.
    func fetch<T: Decodable>(from url: URL, as type: T.Type = T.self) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding failure on: \(url.absoluteString)")
            throw NetworkError.decodingError(error)
        }
    }
}