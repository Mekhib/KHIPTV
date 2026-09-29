import Foundation


@propertyWrapper
struct FlexibleID: Decodable {
    var wrappedValue: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            wrappedValue = intValue
        } else if let stringValue = try? container.decode(String.self), let intValue = Int(stringValue) {
            wrappedValue = intValue
        } else {
            wrappedValue = 0 
        }
    }
}

// MARK: - Xtream IPTV DTOs

struct ChannelDTO: Decodable {
    @FlexibleID var streamId: Int
    let name: String
    let streamIcon: String?
    let categoryId: String?
    let epgChannelId: String?
    let isAdult: Int?
    let tvArchive: Int?
    let num: Int?
    
    enum CodingKeys: String, CodingKey {
        case streamId = "stream_id"
        case name
        case streamIcon = "stream_icon"
        case categoryId = "category_id"
        case epgChannelId = "epg_channel_id"
        case isAdult = "is_adult"
        case tvArchive = "tv_archive"
        case num
    }
    
    var supportsCatchup: Bool { tvArchive == 1 }
    var isAdultChannel: Bool { isAdult == 1 }
    var cleanEpgId: String? {
        guard let id = epgChannelId, !id.isEmpty else { return nil }
        return id
    }
}

struct MovieDTO: Decodable {
    @FlexibleID var streamId: Int
    let name: String
    let streamIcon: String?
    let containerExtension: String?
    let categoryId: String?
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case streamId = "stream_id"
        case name
        case streamIcon = "stream_icon"
        case containerExtension = "container_extension"
        case categoryId = "category_id"
        case rating
    }
}

struct SeriesDTO: Decodable {
    @FlexibleID var seriesId: Int
    let name: String
    let cover: String?
    let plot: String?
    let cast: String?
    let categoryId: String?
    let rating: String?
    
    enum CodingKeys: String, CodingKey {
        case seriesId = "series_id"
        case name, cover, plot, cast, rating
        case categoryId = "category_id"
    }
}

struct SeriesInfoResponseDTO: Decodable {
    let episodes: [String: [EpisodeDTO]] // Keys are season numbers (e.g., "1", "2")
}

struct EpisodeDTO: Decodable {
    let id: String 
    let episodeNum: Int?
    let title: String
    let containerExtension: String?
    let plot: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case episodeNum = "episode_num"
        case containerExtension = "container_extension"
        case info
    }
    
    // Custom decoding to extract the nested plot from Xtream's "info" object
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        episodeNum = try container.decodeIfPresent(Int.self, forKey: .episodeNum)
        title = try container.decode(String.self, forKey: .title)
        containerExtension = try container.decodeIfPresent(String.self, forKey: .containerExtension)
        
        let info = try? container.decodeIfPresent([String: String].self, forKey: .info)
        plot = info??["plot"]
    }
}

// MARK: - TMDB Enrichment DTOs

struct TMDBResponseDTO<T: Decodable>: Decodable {
    let results: [T]
}

struct TMDBMediaDTO: Decodable {
    let id: Int
    let title: String? // Movies use 'title'
    let name: String?  // TV Shows use 'name'
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
    }
}

struct TMDBCreditsDTO: Decodable {
    let cast: [TMDBCastMemberDTO]
}

struct TMDBCastMemberDTO: Decodable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

struct TMDBPersonCreditsDTO: Decodable {
    let cast: [TMDBMediaDTO] 
}

extension TMDBService {
    func fetchActorCredits(personId: Int) async throws -> [TMDBMediaDTO] {
        guard let url = URL(string: "\(baseURL)/person/\(personId)/combined_credits?api_key=\(apiKey)") else {
            throw NetworkError.invalidURL
        }
        let response: TMDBPersonCreditsDTO = try await apiClient.fetch(from: url)
        return response.cast.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
    }
}