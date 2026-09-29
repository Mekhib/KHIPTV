import Foundation
import SwiftData

extension Series {
    var isFavorite: Bool {
        return false 
    }
    
    var lastWatchedDate: Date? {
        episodes?.compactMap(\.lastWatchedDate).max()
    }
    
    var lastWatchedEpisode: Episode? {
        episodes?.compactMap { ep -> (Episode, Date)? in
            guard let date = ep.lastWatchedDate else { return nil }
            return (ep, date)
        }.max(by: { $0.1 < $1.1 })?.0
    }
    
    var progressPercentage: Double {
        guard let lastEp = lastWatchedEpisode else { return 0.0 }
        return lastEp.progressPercentage
    }
}

extension Episode {
    var progressPercentage: Double {
        guard duration > 0 else { return 0.0 }
        return playbackPosition / duration
    }
}

extension Channel {
    var categoryName: String? {
        if name.contains("|") {
            return name.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespaces)
        }
        return categoryId
    }
    
    var currentProgramTitle: String? {
        return nil
    }
    
    var currentProgramDescription: String? {
        return nil
    }
}