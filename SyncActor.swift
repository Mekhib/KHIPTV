import Foundation
import SwiftData

@ModelActor
actor SyncManager {
    
    /// Syncs Live TV Channels from the network into SwiftData
    func syncChannels(from dtos: [ChannelDTO]) throws {
        // Fetch existing channels to avoid duplicates and perform updates
        let fetchDescriptor = FetchDescriptor<Channel>()
        let existingChannels = try modelContext.fetch(fetchDescriptor)
        let existingDict = Dictionary(uniqueKeysWithValues: existingChannels.map { ($0.streamId, $0) })
        
        for dto in dtos {
            if let existing = existingDict[dto.streamId] {
                // Update existing record
                existing.name = dto.name
                existing.streamIcon = dto.streamIcon
                existing.categoryId = dto.categoryId
                existing.epgChannelId = dto.cleanEpgId
                existing.isAdult = dto.isAdultChannel
                existing.supportsCatchup = dto.supportsCatchup
            } else {
                // Insert new record
                let newChannel = Channel(
                    streamId: dto.streamId,
                    name: dto.name,
                    streamIcon: dto.streamIcon,
                    categoryId: dto.categoryId,
                    epgChannelId: dto.cleanEpgId,
                    isAdult: dto.isAdultChannel,
                    supportsCatchup: dto.supportsCatchup
                )
                modelContext.insert(newChannel)
            }
        }
        
        try modelContext.save()
    }
    
    /// Syncs Movies from the network into SwiftData
    func syncMovies(from dtos: [MovieDTO]) throws {
        let fetchDescriptor = FetchDescriptor<Movie>()
        let existingMovies = try modelContext.fetch(fetchDescriptor)
        let existingDict = Dictionary(uniqueKeysWithValues: existingMovies.map { ($0.streamId, $0) })
        
        for dto in dtos {
            if let existing = existingDict[dto.streamId] {
                existing.name = dto.name
                existing.streamIcon = dto.streamIcon
                existing.containerExtension = dto.containerExtension
                existing.categoryId = dto.categoryId
            } else {
                let newMovie = Movie(
                    streamId: dto.streamId,
                    name: dto.name,
                    streamIcon: dto.streamIcon,
                    containerExtension: dto.containerExtension,
                    categoryId: dto.categoryId
                )
                modelContext.insert(newMovie)
            }
        }
        
        try modelContext.save()
    }
}


extension SyncManager {
    
    /// Syncs the high-level Series list from the network
    func syncSeries(from dtos: [SeriesDTO]) throws {
        let fetchDescriptor = FetchDescriptor<Series>()
        let existingSeries = try modelContext.fetch(fetchDescriptor)
        let existingDict = Dictionary(uniqueKeysWithValues: existingSeries.map { ($0.seriesId, $0) })
        
        for dto in dtos {
            if let existing = existingDict[dto.seriesId] {
                existing.name = dto.name
                existing.cover = dto.cover
                existing.plot = dto.plot
                existing.categoryId = dto.categoryId
            } else {
                let newSeries = Series(
                    seriesId: dto.seriesId,
                    name: dto.name,
                    cover: dto.cover,
                    plot: dto.plot,
                    categoryId: dto.categoryId
                )
                modelContext.insert(newSeries)
            }
        }
        try modelContext.save()
    }
    
    /// Syncs Episodes for a specific Series. 
    /// Note: We pass the Series PersistentIdentifier so the background actor can safely fetch the model.
    func syncEpisodes(from episodeDict: [String: [EpisodeDTO]], forSeriesId id: PersistentIdentifier) throws {
        guard let series = modelContext.model(for: id) as? Series else { return }
        
        // Clear old episodes to handle provider updates/removals
        series.episodes?.forEach { modelContext.delete($0) }
        var newEpisodes: [Episode] = []
        
        for (seasonString, dtos) in episodeDict {
            let seasonNum = Int(seasonString) ?? 0
            
            for dto in dtos {
                let episode = Episode(
                    episodeId: dto.id,
                    episodeNum: dto.episodeNum ?? 0,
                    seasonNum: seasonNum,
                    title: dto.title,
                    containerExtension: dto.containerExtension,
                    plot: dto.plot
                )
                episode.series = series
                newEpisodes.append(episode)
                modelContext.insert(episode)
            }
        }
        
        series.episodes = newEpisodes
        try modelContext.save()
    }
}

extension SyncManager {
    
    func syncCategories(_ dtos: [CategoryDTO], type: CategoryType) throws {
        let typeString = type.rawValue
        
        let fetchDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.typeRaw == typeString }
        )
        let existing = try modelContext.fetch(fetchDescriptor)
        let existingDict = Dictionary(uniqueKeysWithValues: existing.map { ($0.categoryId, $0) })
        
        for dto in dtos {
            if let entity = existingDict[dto.categoryId] {
                entity.name = dto.categoryName
            } else {
                // Insert new category
                let newCategory = Category(
                    categoryId: dto.categoryId,
                    name: dto.categoryName,
                    type: type
                )
                modelContext.insert(newCategory)
            }
        }
        
        try modelContext.save()
    }
}