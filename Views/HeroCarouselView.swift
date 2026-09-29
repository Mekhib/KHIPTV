import SwiftUI

struct HeroCarouselView: View {
    let items: [DisplayableItem]
    let onPlayTapped: (DisplayableItem) -> Void
    
    @State private var currentIndex = 0
    @State private var timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    
    var currentItem: DisplayableItem {
        items.isEmpty ? MockData.featuredItems[0] : items[currentIndex]
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Crossfading Backdrop Image
            ZStack {
                Rectangle()
                    .fill(Color.black)
                
                if let backdrop = currentItem.backdropURL, let url = URL(string: backdrop) {
                    AsyncImage(url: url) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.black
                    }
                    .id(currentItem.id)
                    .transition(.opacity.animation(.easeInOut(duration: 1.0)))
                } else {
                    // Fallback visual mock background gradient
                    LinearGradient(
                        colors: [Color.indigo.opacity(0.6), Color.black],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                }
            }
            .overlay {
                // Gradient scrims for Apple TV contrast
                LinearGradient(colors: [.black.opacity(0.8), .clear, .black], startPoint: .leading, endPoint: .trailing)
                LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
            }
            .frame(height: 520)
            
            // 2. Metadata Overlay & Action Controls
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 16) {
                    if let subtitle = currentItem.subtitle {
                        Text(subtitle.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.accentColor)
                            .tracking(2)
                    }
                    
                    Text(currentItem.title)
                        .font(.system(size: 54, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    
                    if let overview = currentItem.overview {
                        Text(overview)
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(3)
                            .frame(maxWidth: 700)
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: { onPlayTapped(currentItem) }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play")
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Details")
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // 3. Carousel Pagination Indicators (Screenshot 1)
                HStack(spacing: 10) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: currentIndex == index ? 10 : 8, height: currentIndex == index ? 10 : 8)
                            .animation(.spring(), value: currentIndex)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 40)
        }
        .frame(height: 520)
        .onReceive(timer) { _ in
            guard !items.isEmpty else { return }
            withAnimation {
                currentIndex = (currentIndex + 1) % items.count
            }
        }
    }
}