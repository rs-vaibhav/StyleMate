import SwiftUI

/// Shopping suggestions panel — recommends items to buy based on wardrobe gaps
struct ShoppingSuggestionsView: View {
    let suggestions: [ShoppingSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "bag.fill")
                    .font(.body)
                    .foregroundColor(Theme.accentRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Complete Your Look")
                        .font(.headline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Suggested items based on your wardrobe")
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(Theme.accentYellow)
            }
            
            // Suggestion cards — horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestions) { suggestion in
                        suggestionCard(suggestion)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - Suggestion Card
    
    private func suggestionCard(_ item: ShoppingSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product image from Unsplash
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: item.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 130)
                            .clipped()
                    case .failure(_):
                        fallbackImageView(item)
                    case .empty:
                        ZStack {
                            item.color.color.opacity(0.15)
                            ProgressView()
                                .tint(item.color.color)
                        }
                        .frame(width: 150, height: 130)
                    @unknown default:
                        fallbackImageView(item)
                    }
                }
                .frame(width: 150, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Priority badge
                if item.priority == .high {
                    Text("HOT 🔥")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.orange],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .padding(6)
                }
            }
            
            // Title
            Text(item.title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
            
            // Reason
            Text(item.reason)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            // Shop buttons
            HStack(spacing: 6) {
                if let url = item.amazonURL {
                    Link(destination: url) {
                        HStack(spacing: 3) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 9))
                            Text("Amazon")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(red:1.0,green:0.6,blue:0.0), Color(red:0.95,green:0.5,blue:0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                    }
                }
                
                if let url = item.myntraURL {
                    Link(destination: url) {
                        HStack(spacing: 3) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 9))
                            Text("Myntra")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(red:1.0,green:0.24,blue:0.50), Color(red:0.85,green:0.15,blue:0.40)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
    
    // Fallback when image fails to load
    private func fallbackImageView(_ item: ShoppingSuggestion) -> some View {
        ZStack {
            LinearGradient(
                colors: [item.color.color.opacity(0.25), item.color.color.opacity(0.50)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            
            VStack(spacing: 6) {
                Image(systemName: item.category.icon)
                    .font(.title)
                    .foregroundColor(item.color.color)
                Circle()
                    .fill(item.color.color)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
        .frame(width: 150, height: 130)
    }
}
