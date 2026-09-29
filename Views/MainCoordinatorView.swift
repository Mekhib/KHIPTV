import SwiftUI
import SwiftData

struct MainCoordinatorView: View {
    @EnvironmentObject private var repository: MediaRepository
    
    @State private var selectedTab: NavigationTab = .home
    @State private var isSidebarExpanded: Bool = false
    @State private var navPath = NavigationPath()
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.ignoresSafeArea()
            
            NavigationStack(path: $navPath) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeTabView(onMediaSelect: handleMediaSelection)
                        
                    case .movies:
                        MoviesTabView(
                            onMediaSelect: handleMediaSelection,
                            onSeeAllTapped: { navPath.append(AppDestination.seeAllMovies) }
                        )
                        
                    case .tvShows:
                        TVShowsTabView(
                            onMediaSelect: handleMediaSelection,
                            onSeeAllTapped: { navPath.append(AppDestination.seeAllTVShows) }
                        )
                        
                    case .liveTV:
                        LiveTVDashboardView()
                        
                    case .search:
                        UniversalSearchView(onMediaSelect: handleMediaSelection)
                        
                    case .settings:
                        ProductionSettingsView()
                    }
                }
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .item(let item):
                        switch item.action {
                        case .openMovieDetails(let movie):
                            MovieDetailsView(movie: movie)
                        case .openSeriesDetails(let series):
                            Text("Series Details: \(series.name)") // Replace with SeriesDetailsView when ready
                        }
                        
                    case .seeAllMovies:
                        SeeAllMoviesView(onMediaSelect: handleMediaSelection)
                        
                    case .seeAllTVShows:
                        SeeAllTVShowsView(onMediaSelect: handleMediaSelection)
                    }
                }
            }
            
            SidebarView(selectedTab: $selectedTab, isExpanded: $isSidebarExpanded)
        }
        .onChange(of: selectedTab) { _, _ in
            navPath.removeLast(navPath.count)
        }
    }
    
    private func handleMediaSelection(_ item: DisplayableItem) {
        navPath.append(AppDestination.item(item))
    }
}