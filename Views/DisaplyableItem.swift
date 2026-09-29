import Foundation
import SwiftData

enum MediaSelectionAction: Hashable {
    case openMovieDetails(Movie)
    case openSeriesDetails(Series)
}

struct DisplayableItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let overview: String?
    let backdropURL: String?
    let posterURL: String?
    let badgeText: String?
    let progress: Double?
    let action: MediaSelectionAction
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DisplayableItem, rhs: DisplayableItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension DisplayableItem {
    init(movie: Movie) {
        self.id = "movie_\(movie.streamId)"
        self.title = movie.name
        self.subtitle = "Movie"
        self.overview = movie.overview
        self.backdropURL = movie.backdropPath ?? movie.highResPosterPath ?? movie.streamIcon
        self.posterURL = movie.highResPosterPath ?? movie.streamIcon
        self.badgeText = movie.containerExtension?.uppercased()
        self.progress = movie.progressPercentage > 0 ? movie.progressPercentage : nil
        self.action = .openMovieDetails(movie)
    }
    
    init(series: Series) {
        self.id = "series_\(series.seriesId)"
        self.title = series.name
        self.subtitle = "TV Series"
        self.overview = series.plot
        self.backdropURL = series.backdropPath ?? series.cover
        self.posterURL = series.highResPosterPath ?? series.cover
        self.badgeText = nil
        self.progress = series.progressPercentage > 0 ? series.progressPercentage : nil
        self.action = .openSeriesDetails(series)
    }
}