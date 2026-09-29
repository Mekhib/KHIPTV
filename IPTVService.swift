import Foundation

class XtreamService {
    private let apiClient = APIClient()
    
    private let baseURL = "http://pro.ccuhd.top"
    private let username: String
    private let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    
    func fetchLiveChannels() async throws -> [ChannelDTO] {
        let url = try buildURL(action: "get_live_streams")
        return try await apiClient.fetch(from: url)
    }
    
    func fetchMovies() async throws -> [MovieDTO] {
        let url = try buildURL(action: "get_vod_streams")
        return try await apiClient.fetch(from: url)
    }
    
    func fetchSeries() async throws -> [SeriesDTO] {
        let url = try buildURL(action: "get_series")
        return try await apiClient.fetch(from: url)
    }
    
    func fetchEpisodes(for seriesId: Int) async throws -> [String: [EpisodeDTO]] {
        let urlString = "\(baseURL)/player_api.php?username=\(username)&password=\(password)&action=get_series_info&series_id=\(seriesId)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        let response: SeriesInfoResponseDTO = try await apiClient.fetch(from: url)
        return response.episodes
    }
    
    
    
    private func buildURL(action: String) throws -> URL {
        let urlString = "\(baseURL)/player_api.php?username=\(username)&password=\(password)&action=\(action)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return url
    }
}

extension XtreamService {
    
    func fetchLiveCategories() async throws -> [CategoryDTO] {
        let url = try buildURL(action: "get_live_categories") // Uses buildURL helper[cite: 5]
        return try await apiClient.fetch(from: url)           // Uses generic APIClient[cite: 3]
    }

    func fetchMovieCategories() async throws -> [CategoryDTO] {
        let url = try buildURL(action: "get_vod_categories")[cite: 5]
        return try await apiClient.fetch(from: url)[cite: 3]
    }

    func fetchSeriesCategories() async throws -> [CategoryDTO] {
        let url = try buildURL(action: "get_series_categories")[cite: 5]
        return try await apiClient.fetch(from: url)[cite: 3]
    }
}