import SwiftUI

struct LiveEPGPreviewPanel: View {
    let channel: Channel?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Artwork
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.4))
                
                if let channel = channel, let logoURL = channel.streamIcon, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.black.opacity(0.8)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                // Gradient Scrim for EPG text contrast
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6), .black.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            )
            
            // Program Information Overlay
            if let channel = channel {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer()
                    
                    Text("Now Playing...")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(channel.currentProgramTitle ?? "Animals and Nature")
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(radius: 8)
                    
                    Text(channel.currentProgramDescription ?? "Big cat expert Boone Smith follows a strange trail of carnage and death to track cats in Patagonia. He documents their behavior from kittens to killers.")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 550)
                    
                    // Time Scrubber Progress
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: geo.size.width * 0.65, height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack {
                            Text("01:52:37")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("02:10:46")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(40)
            } else {
                VStack {
                    Spacer()
                    Text("Select a channel to view live guide")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.leading, 10)
    }
}