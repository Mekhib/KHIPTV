import SwiftUI

struct MediaShelfView: View {
    let title: String
    let items: [DisplayableItem]
    let onSelect: (DisplayableItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 60)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 30) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            MediaCardView(item: item)
                        }
                        .buttonStyle(.card) 
                    }
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            }
        }
    }
}