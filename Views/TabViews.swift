import SwiftUI
import SwiftData

struct HomeTabView: View {
    let onMediaSelect: (DisplayableItem) -> Void
    let onChannelSelect: (Channel) -> Void
    let onNavigateTab: (Int) -> Void 
    
    // SwiftData Queries
    @Query(sort: \Movie.name) private var allMovies: [Movie]
    @Query(sort: \Series.name) private var allSeries: [Series]
    @Query(sort: \Channel.name) private var allChannels: [Channel]
    
   
    
    private var continueWatchingItems: [DisplayableItem] {
        var items: [(item: DisplayableItem, date: Date)] = []
        
        for movie in allMovies {
            if movie.progressPercentage > 0.05 && movie.progressPercentage < 0.95 {
                let date = movie.lastWatchedDate ?? .distantPast
                items.append((DisplayableItem(movie: movie), date))
            }
        }
        
        for series in allSeries {
            if series.progressPercentage > 0.05 && series.progressPercentage < 0.95 {
                let date = series.lastWatchedDate ?? .distantPast
                items.append((DisplayableItem(series: series), date))
            }
        }
        
        return items.sorted(by: { $0.date > $1.date }).map(\.item)
    }
    
    private var favoriteItems: [DisplayableItem] {
        var items: [DisplayableItem] = []
        
        for movie in allMovies where movie.isFavorite {
            items.append(DisplayableItem(movie: movie))
        }
        
        for series in allSeries where series.isFavorite {
            items.append(DisplayableItem(series: series))
        }
        
        return items
    }
    
    private var favoriteChannels: [Channel] {
        allChannels.filter { $0.isFavorite }
    }
    
    private var recentChannels: [Channel] {
        allChannels
            .filter { $0.lastWatchedDate != nil }
            .sorted(by: { ($0.lastWatchedDate ?? .distantPast) > ($1.lastWatchedDate ?? .distantPast) })
    }
    
    private var featuredHeroItems: [DisplayableItem] {
        let featuredMovies = Array(allMovies.prefix(3)).map { DisplayableItem(movie: $0) }
        let featuredSeries = Array(allSeries.prefix(2)).map { DisplayableItem(series: $0) }
        return (featuredMovies + featuredSeries).shuffled()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                
                if !featuredHeroItems.isEmpty {
                    HeroSpotlightView(
                        items: featuredHeroItems,
                        onMediaSelect: onMediaSelect
                    )
                    .padding(.top, 20)
                }
                
                if !continueWatchingItems.isEmpty {
                    CatalogRowView(
                        title: "Continue Watching",
                        items: continueWatchingItems,
                        onMediaSelect: onMediaSelect
                    )
                }
                
                if !favoriteChannels.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Favorite Channels")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button("See Live TV Guide") {
                                onNavigateTab(1)
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 50)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 24) {
                                ForEach(favoriteChannels) { channel in
                                    HomeChannelChipCard(channel: channel) {
                                        onChannelSelect(channel)
                                    }
                                }
                            }
                            .padding(.horizontal, 50)
                        }
                    }
                }
                
                if !favoriteItems.isEmpty {
                    CatalogRowView(
                        title: "Favorite Movies & Shows",
                        items: favoriteItems,
                        onMediaSelect: onMediaSelect
                    )
                }
                
                if !recentChannels.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recently Watched Channels")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 24) {
                                ForEach(recentChannels) { channel in
                                    HomeChannelChipCard(channel: channel) {
                                        onChannelSelect(channel)
                                    }
                                }
                            }
                            .padding(.horizontal, 50)
                        }
                    }
                }
                
                if !allMovies.isEmpty {
                    CatalogRowView(
                        title: "Popular Movies",
                        items: Array(allMovies.prefix(10)).map { DisplayableItem(movie: $0) },
                        onMediaSelect: onMediaSelect
                    )
                }
                
                if !allSeries.isEmpty {
                    CatalogRowView(
                        title: "Popular TV Series",
                        items: Array(allSeries.prefix(10)).map { DisplayableItem(series: $0) },
                        onMediaSelect: onMediaSelect
                    )
                }
            }
            .padding(.bottom, 60)
        }
    }
}

struct HomeChannelChipCard: View {
    let channel: Channel
    let onSelect: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Channel Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                    
                    if let logoURL = channel.streamIcon, let url = URL(string: logoURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fit).padding(6)
                            } else {
                                Image(systemName: "tv").foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "tv").foregroundColor(.gray)
                    }
                }
                .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(channel.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(channel.countryPrefix)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                if channel.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding(12)
            .frame(width: 280, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isFocused ? Color.white.opacity(0.2) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused ? Color.white : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isFocused)
        }
        .buttonStyle(.card)
        .focused($isFocused)
    }
}


struct MoviesTabView: View {
    let onMediaSelect: (DisplayableItem) -> Void
    let onSeeAllTapped: () -> Void
    
    @Query(filter: #Predicate<Category> { $0.typeRaw == "movie" }, sort: \.name) private var categories: [Category]
    @Query(sort: \Movie.name) private var allMovies: [Movie]
    
    private var shelves: [(title: String, items: [DisplayableItem])] {
        var builtShelves: [(String, [DisplayableItem])] = []
        
        // 1. Continue Watching Shelf (Matches Movie.progressPercentage)
        let continueWatching = allMovies.filter { $0.progressPercentage > 0.05 && $0.progressPercentage < 0.95 }
        if !continueWatching.isEmpty {
            builtShelves.append(("Continue Watching", continueWatching.map { DisplayableItem(movie: $0) }))
        }
        
        // 2. Favorites Shelf (Matches Movie.isFavorite)
        let favorites = allMovies.filter { $0.isFavorite == true }
        if !favorites.isEmpty {
            builtShelves.append(("Favorite Movies", favorites.map { DisplayableItem(movie: $0) }))
        }
        
        // 3. Category Shelves
        let grouped = Dictionary(grouping: allMovies, by: { $0.categoryId })
        for category in categories {
            if let moviesInCategory = grouped[category.categoryId], !moviesInCategory.isEmpty {
                builtShelves.append((category.name, moviesInCategory.map { DisplayableItem(movie: $0) }))
            }
        }
        
        return builtShelves
    }
    
    private var featuredMovies: [DisplayableItem] {
        Array(allMovies.prefix(5)).map { DisplayableItem(movie: $0) }
    }
    
    var body: some View {
        if allMovies.isEmpty {
            VStack {
                ProgressView().scaleEffect(1.5)
                Text("Syncing Movies...").foregroundColor(.gray).padding(.top, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            CatalogSectionView(
                featured: featuredMovies,
                shelves: shelves,
                onMediaSelect: onMediaSelect,
                seeAllTitle: "Browse All Movies",
                onSeeAllTapped: onSeeAllTapped
            )
        }
    }
}

struct TVShowsTabView: View {
    let onMediaSelect: (DisplayableItem) -> Void
    let onSeeAllTapped: () -> Void
    
    @Query(filter: #Predicate<Category> { $0.typeRaw == "series" }, sort: \.name) private var categories: [Category]
    @Query(sort: \Series.name) private var allSeries: [Series]
    
    private var shelves: [(title: String, items: [DisplayableItem])] {
        var builtShelves: [(String, [DisplayableItem])] = []
        
        // 1. Continue Watching Shelf (Matches Series.progressPercentage derived from Episodes)
        let continueWatching = allSeries.filter { $0.progressPercentage > 0.05 && $0.progressPercentage < 0.95 }
        if !continueWatching.isEmpty {
            builtShelves.append(("Continue Watching", continueWatching.map { DisplayableItem(series: $0) }))
        }
        
        // 2. Favorites Shelf
        let favorites = allSeries.filter { $0.isFavorite == true }
        if !favorites.isEmpty {
            builtShelves.append(("Favorite TV Shows", favorites.map { DisplayableItem(series: $0) }))
        }
        
        // 3. Category Shelves
        let grouped = Dictionary(grouping: allSeries, by: { $0.categoryId })
        for category in categories {
            if let seriesInCategory = grouped[category.categoryId], !seriesInCategory.isEmpty {
                builtShelves.append((category.name, seriesInCategory.map { DisplayableItem(series: $0) }))
            }
        }
        
        return builtShelves
    }
    
    private var featuredSeries: [DisplayableItem] {
        Array(allSeries.prefix(5)).map { DisplayableItem(series: $0) }
    }
    
    var body: some View {
        if allSeries.isEmpty {
            VStack {
                ProgressView().scaleEffect(1.5)
                Text("Syncing TV Shows...").foregroundColor(.gray).padding(.top, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            CatalogSectionView(
                featured: featuredSeries,
                shelves: shelves,
                onMediaSelect: onMediaSelect,
                seeAllTitle: "Browse All TV Shows",
                onSeeAllTapped: onSeeAllTapped
            )
        }
    }
}