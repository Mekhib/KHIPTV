import Foundation

enum PlayableMedia {
    case live(Channel)
    case movie(Movie)
    case episode(Episode)
    
    var title: String {
        switch self {
        case .live(let channel):
            return channel.name
        case .movie(let movie):
            return movie.name
        case .episode(let episode):
            return episode.title
        }
    }
    
    var streamId: Int {
        switch self {
        case .live(let channel):
            return channel.streamId
        case .movie(let movie):
            return movie.streamId
        case .episode(let episode):
            return episode.episodeId
        }
    }
    
    func streamURL(baseURL: String, username: String, password: String) -> URL? {
        let cleanBaseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let urlString: String
        
        switch self {
        case .live(let channel):
            urlString = "\(cleanBaseURL)/\(username)/\(password)/\(channel.streamId)"
            
        case .movie(let movie):
            let ext = movie.containerExtension ?? "mp4"
            urlString = "\(cleanBaseURL)/movie/\(username)/\(password)/\(movie.streamId).\(ext)"
            
        case .episode(let episode):
            let ext = episode.containerExtension ?? "mp4"
            urlString = "\(cleanBaseURL)/series/\(username)/\(password)/\(episode.episodeId).\(ext)"
        }
        
        return URL(string: urlString)
    }
}