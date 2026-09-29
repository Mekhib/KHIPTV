import Foundation

class TMDBService {
    private let apiClient = APIClient()
    private let apiKey: String
    private let baseURL = "https://api.themoviedb.org/3"
    
    // TMDB Base Image URL (w500 for posters, original for backdrops)
    let posterBaseURL = "https://image.tmdb.org/t/p/w500"
    let backdropBaseURL = "https://image.tmdb.org/t/p/w1280"
    let profileBaseURL = "https://image.tmdb.org/t/p/w185"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Search
    
    func searchMovie(title: String) async throws -> TMDBMediaDTO? {
        let sanitizedTitle = sanitizeTitle(title)
        guard let encoded = sanitizedTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encoded)") else {
            throw NetworkError.invalidURL
        }

        let response: TMDBResponseDTO<TMDBMediaDTO> = try await apiClient.fetch(from: url)
        return response.results.first
    }

    // MARK: - Cast & Crew
    
    func fetchMovieCredits(tmdbId: Int) async throws -> [TMDBCastMemberDTO] {
        guard let url = URL(string: "\(baseURL)/movie/\(tmdbId)/credits?api_key=\(apiKey)") else {
            throw NetworkError.invalidURL
        }

        let response: TMDBCreditsDTO = try await apiClient.fetch(from: url)
        return response.cast
    }

    // IPTV providers usually include release years or resolution tags in movie titles (e.g., "The Matrix (1999) 4K")
    // This helper cleans up the title so TMDB search works accurately.
    private func sanitizeTitle(_ title: String) -> String {
        var cleaned = title
        // Remove common resolution & language tags
        let patterns = ["\\[.*?\\]", "\\(.*?\\)", "4K", "1080p", "UHD", "FHD", "HEVC", "MULTi", "60fps"]
        for pattern in patterns {
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension TMDBService {
    func searchTVShow(title: String) async throws -> TMDBMediaDTO? {
        let sanitizedTitle = sanitizeTitle(title)
        guard let encoded = sanitizedTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/tv?api_key=\(apiKey)&query=\(encoded)") else {
            throw NetworkError.invalidURL
        }

        let response: TMDBResponseDTO<TMDBMediaDTO> = try await apiClient.fetch(from: url)
        return response.results.first
    }
}