import Foundation
import SwiftData

@Model
final class Channel {
    // Core Xtream Data
    @Attribute(.unique) var streamId: Int
    var name: String
    var streamIcon: String?
    var categoryId: String?
    var epgChannelId: String?
    var isAdult: Bool
    var supportsCatchup: Bool
    
    init(streamId: Int, name: String, streamIcon: String?, categoryId: String?, epgChannelId: String?, isAdult: Bool, supportsCatchup: Bool) {
        self.streamId = streamId
        self.name = name
        self.streamIcon = streamIcon
        self.categoryId = categoryId
        self.epgChannelId = epgChannelId
        self.isAdult = isAdult
        self.supportsCatchup = supportsCatchup
    }
}

@Model
final class Movie {
    // Core Xtream Data
    @Attribute(.unique) var streamId: Int
    var name: String
    var streamIcon: String?
    var containerExtension: String?
    var categoryId: String?
    
    // TMDB Enriched Data
    var tmdbId: Int?
    var overview: String?
    var highResPosterPath: String?
    var backdropPath: String?
    var tmdbRating: Double?
    
    // Relationships
    @Relationship(inverse: \Actor.movies) var cast: [Actor]?
    
    init(streamId: Int, name: String, streamIcon: String?, containerExtension: String?, categoryId: String?) {
        self.streamId = streamId
        self.name = name
        self.streamIcon = streamIcon
        self.containerExtension = containerExtension
        self.categoryId = categoryId
    }
}

@Model
final class Series {
    // Core Xtream Data
    @Attribute(.unique) var seriesId: Int
    var name: String
    var cover: String?
    var plot: String?
    var categoryId: String?
    
    // TMDB Enriched Data
    var tmdbId: Int?
    var highResPosterPath: String?
    var backdropPath: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade) var episodes: [Episode]?
    @Relationship(inverse: \Actor.series) var cast: [Actor]?
    
    init(seriesId: Int, name: String, cover: String?, plot: String?, categoryId: String?) {
        self.seriesId = seriesId
        self.name = name
        self.cover = cover
        self.plot = plot
        self.categoryId = categoryId
    }
}

@Model
final class Episode {
    @Attribute(.unique) var episodeId: String
    var episodeNum: Int
    var seasonNum: Int
    var title: String
    var containerExtension: String?
    var plot: String?
    
    // Relationships
    var series: Series?
    
    init(episodeId: String, episodeNum: Int, seasonNum: Int, title: String, containerExtension: String?, plot: String?) {
        self.episodeId = episodeId
        self.episodeNum = episodeNum
        self.seasonNum = seasonNum
        self.title = title
        self.containerExtension = containerExtension
        self.plot = plot
    }
}

@Model
final class Actor {
    @Attribute(.unique) var tmdbId: Int
    var name: String
    var profilePath: String?
    
    // Relationships
    var movies: [Movie]?
    var series: [Series]?
    
    init(tmdbId: Int, name: String, profilePath: String?) {
        self.tmdbId = tmdbId
        self.name = name
        self.profilePath = profilePath
    }
}

import Foundation
import SwiftData

extension Movie {
    // New User State Properties
    var isFavorite: Bool = false
    var playbackPosition: Double = 0.0 
    var duration: Double = 0.0
    var lastWatchedDate: Date? = nil
    
    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return playbackPosition / duration
    }
}

extension Episode {
    var playbackPosition: Double = 0.0
    var duration: Double = 0.0
    var lastWatchedDate: Date? = nil
}


extension Channel {
    var isFavorite: Bool = false
    var lastWatchedDate: Date? = nil
}