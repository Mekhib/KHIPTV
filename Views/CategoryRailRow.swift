import SwiftUI

struct CategoryRailRow: View {
    let category: ChannelCategoryItem
    let isSelected: Bool
    let onSelect: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Category Flag or Icon
                if let flag = category.flagEmoji {
                    Text(flag)
                        .font(.system(size: 30))
                        .frame(width: 44, height: 44)
                } else if let iconName = category.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray)
                        .frame(width: 44, height: 44)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected || isFocused ? .white : .white.opacity(0.6))
                    
                    Text("\(category.channelCount) Channels")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isFocused ? Color.white.opacity(0.2) : (isSelected ? Color.white.opacity(0.08) : Color.clear))
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isFocused)
        }
        .buttonStyle(.plain)
        .focused($isFocused)
    }
}