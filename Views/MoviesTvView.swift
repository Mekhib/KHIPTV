import SwiftUI
import SwiftData

struct SeeAllMoviesView: View {
    let onMediaSelect: (DisplayableItem) -> Void
    
    @Query(sort: \Movie.name) private var allMovies: [Movie]
    @State private var searchText = ""
    
    private var filteredMovies: [Movie] {
        if searchText.isEmpty { return allMovies }
        return allMovies.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("All Movies (\(filteredMovies.count))")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 60)
                    .padding(.top, 40)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 40)], spacing: 40) {
                    ForEach(filteredMovies) { movie in
                        let item = DisplayableItem(movie: movie)
                        Button(action: { onMediaSelect(item) }) {
                            MediaCardView(item: item)
                        }
                        .buttonStyle(.card)
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .searchable(text: $searchText, prompt: "Search all movies...")
    }
}

struct SeeAllTVShowsView: View {
    let onMediaSelect: (DisplayableItem) -> Void
    
    @Query(sort: \Series.name) private var allSeries: [Series]
    @State private var searchText = ""
    
    private var filteredSeries: [Series] {
        if searchText.isEmpty { return allSeries }
        return allSeries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("All TV Shows (\(filteredSeries.count))")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 60)
                    .padding(.top, 40)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 40)], spacing: 40) {
                    ForEach(filteredSeries) { series in
                        let item = DisplayableItem(series: series)
                        Button(action: { onMediaSelect(item) }) {
                            MediaCardView(item: item)
                        }
                        .buttonStyle(.card)
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .searchable(text: $searchText, prompt: "Search all TV shows...")
    }
}