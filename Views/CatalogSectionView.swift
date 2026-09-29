import SwiftUI

struct CatalogSectionView: View {
    let featured: [DisplayableItem]
    let shelves: [(title: String, items: [DisplayableItem])]
    let onMediaSelect: (DisplayableItem) -> Void
    
    var seeAllTitle: String? = nil
    var onSeeAllTapped: (() -> Void)? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 40) {
                // Top Hero Slideshow Banner
                if !featured.isEmpty {
                    HeroCarouselView(items: featured, onPlayTapped: onMediaSelect)
                }
                
                // Categorized Horizontal Shelves
                LazyVStack(spacing: 40) {
                    ForEach(shelves, id: \.title) { shelf in
                        MediaShelfView(title: shelf.title, items: shelf.items, onSelect: onMediaSelect)
                    }
                    
                    // Bottom "See All" Action Button
                    if let seeAllTitle = seeAllTitle, let onSeeAllTapped = onSeeAllTapped {
                        VStack(spacing: 12) {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 60)
                                .padding(.top, 20)
                            
                            Button(action: onSeeAllTapped) {
                                HStack(spacing: 12) {
                                    Text(seeAllTitle)
                                    Image(systemName: "grid.circle.fill")
                                }
                                .font(.system(size: 22, weight: .bold))
                                .padding(.horizontal, 36)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 10)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}