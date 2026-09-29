import Foundation
import SwiftData

@MainActor
class MediaRepository: ObservableObject {
    private let xtreamService: XtreamService
    private let tmdbService: TMDBService
    private let syncManager: SyncManager
    private let modelContext: ModelContext
    
    @Published var isSyncing = false

    init(xtreamService: XtreamService, tmdbService: TMDBService, modelContainer: ModelContainer) {
        self.xtreamService = xtreamService
        self.tmdbService = tmdbService
        self.syncManager = SyncManager(modelContainer: modelContainer)
        self.modelContext = modelContainer.mainContext
    }

    // MARK: - Database Sync Operations
    
    /// Pulls raw channels & movies from Xtream and stores them in local database
    func performFullSync() async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // 1. Concurrent network requests for channels and movies
            async let channelsTask = xtreamService.fetchLiveChannels()
            async let moviesTask = xtreamService.fetchMovies()
            
            let (channelDTOs, movieDTOs) = try await (channelsTask, moviesTask)
            
            // 2. Persist to SwiftData in background thread via ModelActor
            try await syncManager.syncChannels(from: channelDTOs)
            try await syncManager.syncMovies(from: movieDTOs)
            
            print("Successfully synced \(channelDTOs.count) channels and \(movieDTOs.count) movies.")
        } catch {
            print("Failed to sync media: \(error)")
        }
    }

    // MARK: - On-Demand TMDB Enrichment
    
    /// Call this when a user focuses/selects a movie card to load high-res art and cast
    func enrichMovieIfNeeded(_ movie: Movie) async {
        // Skip if already enriched
        guard movie.tmdbId == nil else { return }

        do {
            // 1. Search TMDB for movie metadata
            guard let tmdbDTO = try await tmdbService.searchMovie(title: movie.name) else { return }

            // 2. Fetch Cast
            let castDTOs = (try? await tmdbService.fetchMovieCredits(tmdbId: tmdbDTO.id)) ?? []

            // 3. Update SwiftData Model on Main Thread (UI updates automatically)
            movie.tmdbId = tmdbDTO.id
            movie.overview = tmdbDTO.overview
            movie.tmdbRating = tmdbDTO.voteAverage
            
            if let poster = tmdbDTO.posterPath {
                movie.highResPosterPath = "\(tmdbService.posterBaseURL)\(poster)"
            }
            if let backdrop = tmdbDTO.backdropPath {
                movie.backdropPath = "\(tmdbService.backdropBaseURL)\(backdrop)"
            }

            // 4. Connect Actors
            var actorModels: [Actor] = []
            for castDTO in castDTOs.prefix(10) { // Limit to top 10 cast members
                let actorID = castDTO.id
                
                // Fetch or create Actor
                let fetchDescriptor = FetchDescriptor<Actor>(predicate: #Predicate { $0.tmdbId == actorID })
                if let existingActor = (try? modelContext.fetch(fetchDescriptor))?.first {
                    actorModels.append(existingActor)
                } else {
                    let profileURL = castDTO.profilePath.map { "\(tmdbService.profileBaseURL)\($0)" }
                    let newActor = Actor(tmdbId: actorID, name: castDTO.name, profilePath: profileURL)
                    modelContext.insert(newActor)
                    actorModels.append(newActor)
                }
            }
            
            movie.cast = actorModels
            try modelContext.save()
            
        } catch {
            print("TMDB Enrichment error for '\(movie.name)': \(error)")
        }
    }
}

extension MediaRepository {
    
    func performFullSync() async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // 1. Fetch all top-level catalogs concurrently
            async let channelsTask = xtreamService.fetchLiveChannels()
            async let moviesTask = xtreamService.fetchMovies()
            async let seriesTask = xtreamService.fetchSeries()
            
            let (channelDTOs, movieDTOs, seriesDTOs) = try await (channelsTask, moviesTask, seriesTask)
            
            // 2. Persist to SwiftData
            try await syncManager.syncChannels(from: channelDTOs)
            try await syncManager.syncMovies(from: movieDTOs)
            try await syncManager.syncSeries(from: seriesDTOs)
            
            print("Successfully synced \(channelDTOs.count) channels, \(movieDTOs.count) movies, and \(seriesDTOs.count) series.")
        } catch {
            print("Failed to sync media: \(error)")
        }
    }
    
    // MARK: - Lazy Loading Series Data
    
    /// Call this when a user opens a Series Detail View.
    /// It fetches the episodes from Xtream and the high-res art from TMDB concurrently.
    func loadSeriesDetailsIfNeeded(_ series: Series) async {
        
        // Fire both network requests concurrently
        async let episodesTask = fetchAndSyncEpisodes(for: series)
        async let tmdbTask = enrichSeriesIfNeeded(series)
        
        _ = await (episodesTask, tmdbTask)
    }
    
    private func fetchAndSyncEpisodes(for series: Series) async {
        // Skip if we already have episodes
        guard series.episodes == nil || series.episodes?.isEmpty == true else { return }
        
        do {
            let episodesDict = try await xtreamService.fetchEpisodes(for: series.seriesId)
            // Pass the persistentModelID to the background actor
            try await syncManager.syncEpisodes(from: episodesDict, forSeriesId: series.persistentModelID)
        } catch {
            print("Failed to fetch episodes for series \(series.name): \(error)")
        }
    }
    
    private func enrichSeriesIfNeeded(_ series: Series) async {
        guard series.tmdbId == nil else { return }

        do {
            guard let tmdbDTO = try await tmdbService.searchTVShow(title: series.name) else { return }

            series.tmdbId = tmdbDTO.id
            if let poster = tmdbDTO.posterPath {
                series.highResPosterPath = "\(tmdbService.posterBaseURL)\(poster)"
            }
            if let backdrop = tmdbDTO.backdropPath {
                series.backdropPath = "\(tmdbService.backdropBaseURL)\(backdrop)"
            }
            try modelContext.save()
            
        } catch {
            print("TMDB Enrichment error for TV show '\(series.name)': \(error)")
        }
    }

        func syncProviderCategories() async {
        do {
            async let liveCats = xtreamService.fetchLiveCategories()
            async let movieCats = xtreamService.fetchMovieCategories()
            async let seriesCats = xtreamService.fetchSeriesCategories()
            
            let (live, movie, series) = try await (liveCats, movieCats, seriesCats)
            
            try await syncManager.syncCategories(live, type: .live)
            try await syncManager.syncCategories(movie, type: .movie)
            try await syncManager.syncCategories(series, type: .series)
            
            print("Successfully synced provider categories.")
        } catch {
            print("Failed to sync provider categories: \(error)")
        }
    }
}

