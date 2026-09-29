import SwiftUI

struct MediaCardView: View {
    let item: DisplayableItem
    let width: CGFloat
    let height: CGFloat
    
    @FocusState private var isFocused: Bool
    
    init(item: DisplayableItem, width: CGFloat = 340, height: CGFloat = 200) {
        self.item = item
        self.width = width
        self.height = height
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                // Card Thumbnail Frame
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay {
                        if let posterURL = item.posterURL, let url = URL(string: posterURL) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "tv.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Optional Progress Bar (Continue Watching)
                if let progress = item.progress {
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.black.opacity(0.6)).frame(height: 6)
                                Capsule().fill(Color.white).frame(width: geo.size.width * progress, height: 6)
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                        }
                    }
                }
                
                // Optional Badge
                if let badge = item.badgeText {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(12)
                }
            }
            .scaleEffect(isFocused ? 1.06 : 1.0)
            .shadow(color: isFocused ? .black.opacity(0.6) : .clear, radius: 20, x: 0, y: 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            
            // Labels below card
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isFocused ? .white : .white.opacity(0.8))
                    .lineLimit(1)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(width: width, alignment: .leading)
        }
        .focused($isFocused)
    }
}