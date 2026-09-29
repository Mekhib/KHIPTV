import SwiftUI

// MARK: - Top Guide Header View
struct TopGuideHeaderView: View {
    @Binding var viewMode: LiveTVViewMode
    
    var body: some View {
        HStack {
            Text("Live TV's")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 30) {
                // Time & Weather Mock Data
                HStack(spacing: 10) {
                    Text("12:51")
                        .font(.system(size: 20, weight: .semibold))
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                    Text("24°")
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundColor(.white)
                
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                }
                .buttonStyle(.circleIconButton)
                
                // Profile Avatar Placeholder
                Circle()
                    .fill(Color.red)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
            }
        }
    }
}

struct AlternativeChannelGridView: View {
    let categories: [ChannelCategoryItem]
    @Binding var selectedCategory: ChannelCategoryItem?
    let channels: [Channel]
    let onChannelSelected: (Channel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(categories) { cat in
                        Button(action: { selectedCategory = cat }) {
                            HStack {
                                if let flag = cat.flagEmoji { Text(flag) }
                                Text(cat.name)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(selectedCategory?.id == cat.id ? Color.white : Color.white.opacity(0.1))
                            .foregroundColor(selectedCategory?.id == cat.id ? .black : .white)
                            .cornerRadius(30)
                        }
                        .buttonStyle(.card)
                    }
                }
                .padding(.horizontal, 50)
            }
            .padding(.top, 20)
            
            // Channel Sub-Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 30)], spacing: 30) {
                    ForEach(channels) { channel in
                        GuideChannelCard(channel: channel, isFocused: false) {
                            onChannelSelected(channel)
                        }
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Circle Icon Button Style
struct CircleIconButtonModifier: ButtonStyle {
    var isActive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        CircleIconButton(configuration: configuration, isActive: isActive)
    }
    
    struct CircleIconButton: View {
        let configuration: ButtonStyle.Configuration
        let isActive: Bool
        @FocusState private var isFocused: Bool
        
        var body: some View {
            configuration.label
                .foregroundColor(isFocused || isActive ? .white : .white.opacity(0.7))
                .frame(width: 54, height: 54)
                .background(
                    Circle()
                        .fill(isFocused ? Color.white.opacity(0.3) : (isActive ? Color.white.opacity(0.2) : Color.white.opacity(0.08)))
                )
                .scaleEffect(isFocused ? 1.15 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isFocused)
                .focused($isFocused)
        }
    }
}

extension ButtonStyle where Self == CircleIconButtonModifier {
    static var circleIconButton: CircleIconButtonModifier { CircleIconButtonModifier() }
    static func circleIconButton(isActive: Bool) -> CircleIconButtonModifier { CircleIconButtonModifier(isActive: isActive) }
}