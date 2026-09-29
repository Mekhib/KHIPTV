import SwiftUI
import SwiftData

struct LiveTVGuideView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Channel.name) private var allChannels: [Channel]
    
    let onChannelSelected: (Channel) -> Void
    
    @State private var viewMode: LiveTVViewMode = .guide
    @State private var selectedCategory: ChannelCategoryItem?
    @State private var focusedChannel: Channel?
    
    // Dynamically builds category items based on Channel models
    private var categories: [ChannelCategoryItem] {
        var items: [ChannelCategoryItem] = []
        
        // 1. Favorites Category (Matches Channel.isFavorite)
        let favCount = allChannels.filter { $0.isFavorite }.count
        items.append(ChannelCategoryItem(
            id: "cat_favorites",
            name: "Favorites",
            flagEmoji: nil,
            iconName: "star.fill",
            channelCount: favCount,
            type: .favorites
        ))
        
        // 2. Recents Category (Matches Channel.lastWatchedDate)
        let recentChannels = allChannels.filter { $0.lastWatchedDate != nil }
        items.append(ChannelCategoryItem(
            id: "cat_recents",
            name: "Recents",
            flagEmoji: nil,
            iconName: "clock.fill",
            channelCount: recentChannels.count,
            type: .recents
        ))
        
        // 3. Country/Prefix Filtered Categories
        let grouped = Dictionary(grouping: allChannels, by: { $0.countryPrefix })
        for (prefix, channels) in grouped.sorted(by: { $0.key < $1.key }) {
            items.append(ChannelCategoryItem(
                id: "cat_\(prefix)",
                name: countryName(for: prefix),
                flagEmoji: flagEmoji(for: prefix),
                iconName: nil,
                channelCount: channels.count,
                type: .country(prefix: prefix)
            ))
        }
        
        return items
    }
    
    // Filter channels according to active category
    private var filteredChannels: [Channel] {
        guard let category = selectedCategory else { return allChannels }
        switch category.type {
        case .favorites:
            return allChannels.filter { $0.isFavorite }
        case .recents:
            return allChannels
                .filter { $0.lastWatchedDate != nil }
                .sorted(by: { ($0.lastWatchedDate ?? .distantPast) > ($1.lastWatchedDate ?? .distantPast) })
        case .country(let prefix):
            return allChannels.filter { $0.countryPrefix == prefix }
        case .custom(let name):
            return allChannels.filter { $0.categoryId == name }
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.08, blue: 0.11).ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopGuideHeaderView(viewMode: $viewMode)
                    .padding(.horizontal, 50)
                    .padding(.top, 30)
                
                if viewMode == .guide {
                    HStack(spacing: 0) {
                        // Category Selection Column
                        HStack(spacing: 24) {
                            VStack(spacing: 20) {
                                Button(action: {}) { Image(systemName: "chevron.left").font(.title3) }
                                    .buttonStyle(.circleIconButton)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        viewMode = viewMode == .guide ? .grid : .guide
                                    }
                                }) {
                                    Image(systemName: viewMode == .guide ? "tv" : "rectangle.grid.2x2").font(.title3)
                                }
                                .buttonStyle(.circleIconButton(isActive: viewMode == .guide))
                                
                                Button(action: {
                                    if let favCat = categories.first(where: { $0.id == "cat_favorites" }) {
                                        selectedCategory = favCat
                                    }
                                }) {
                                    Image(systemName: "star.fill").font(.title3)
                                }
                                .buttonStyle(.circleIconButton)
                                
                                Spacer()
                            }
                            .padding(.leading, 30)
                            .padding(.top, 20)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(alignment: .leading, spacing: 16) {
                                    ForEach(categories) { cat in
                                        CategoryRailRow(
                                            category: cat,
                                            isSelected: selectedCategory?.id == cat.id
                                        ) {
                                            selectedCategory = cat
                                        }
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            .frame(width: 260)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Sub-Channels Column
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 20) {
                                ForEach(filteredChannels) { channel in
                                    GuideChannelCard(
                                        channel: channel,
                                        isFocused: focusedChannel?.streamId == channel.streamId
                                    ) {
                                        // Update lastWatchedDate on channel selection
                                        channel.lastWatchedDate = Date()
                                        try? modelContext.save()
                                        
                                        onChannelSelected(channel)
                                    }
                                    .onFocusGesture { isFocused in
                                        if isFocused {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                focusedChannel = channel
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                        }
                        .frame(width: 480)
                        
                        Spacer(minLength: 20)
                        
                        // Live Preview Column
                        LiveEPGPreviewPanel(channel: focusedChannel ?? filteredChannels.first)
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, 50)
                            .padding(.vertical, 20)
                    }
                } else {
                    AlternativeChannelGridView(
                        categories: categories,
                        selectedCategory: $selectedCategory,
                        channels: filteredChannels,
                        onChannelSelected: { channel in
                            channel.lastWatchedDate = Date()
                            try? modelContext.save()
                            onChannelSelected(channel)
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
        .onAppear {
            if selectedCategory == nil { selectedCategory = categories.first }
            if focusedChannel == nil { focusedChannel = filteredChannels.first }
        }
    }
    
    private func countryName(for prefix: String) -> String {
        switch prefix.uppercased() {
        case "US", "USA": return "United States"
        case "UK", "GB": return "United Kingdom"
        case "BR": return "Brazil"
        case "DE": return "Germany"
        case "FR": return "France"
        case "IT": return "Italy"
        case "ZA": return "South Africa"
        case "CN": return "China"
        case "PT": return "Portugal"
        default: return prefix
        }
    }
    
    private func flagEmoji(for prefix: String) -> String {
        let base: UInt32 = 127397
        var usv = String.UnicodeScalarView()
        for i in prefix.uppercased().utf8 {
            if let scalar = UnicodeScalar(base + UInt32(i)) {
                usv.append(scalar)
            }
        }
        return String(usv)
    }
}