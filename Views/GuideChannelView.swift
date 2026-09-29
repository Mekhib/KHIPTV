import SwiftUI

struct GuideChannelCard: View {
    let channel: Channel
    let isFocused: Bool
    let onSelect: () -> Void
    
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                    
                    if let logoURL = channel.streamIcon, let url = URL(string: logoURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(12)
                            default:
                                Image(systemName: "tv")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "tv")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 110, height: 110)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(channel.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("+1.2M Views") 
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(channel.badgeTags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        if channel.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(focused ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(focused ? Color.white.opacity(0.6) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(focused ? 1.04 : 1.0)
            .shadow(color: focused ? Color.black.opacity(0.5) : Color.clear, radius: 15, x: 0, y: 10)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}