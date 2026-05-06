import SwiftUI

struct ShareFitCard: View {
    let suggestion: OutfitSuggestion
    let wardrobeVM: WardrobeViewModel
    let profile: UserProfile
    let weather: WeatherProfile
    
    var body: some View {
        ZStack {
            // Branded Background
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color.black],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle astrology shapes
            Circle()
                .fill(LinearGradient.vibrantAccent.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 40)
                .offset(x: 100, y: -200)
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("StyleMate")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient.vibrantHero)
                        
                        Text(AstrologyEngine.formattedDate(suggestion.date))
                            .font(.callout.weight(.medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Weather & Zodiac
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(weather.temperature)°C \(weather.condition.icon)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text(profile.zodiacSign.symbol)
                            Text(profile.zodiacSign.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundColor(Theme.accentPurple)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                
                // Outfit Board
                OutfitBoardView(
                    topImage: image(for: suggestion.top),
                    bottomImage: image(for: suggestion.bottom),
                    footwearImage: image(for: suggestion.footwear),
                    topColor: suggestion.top?.color.color,
                    bottomColor: suggestion.bottom?.color.color,
                    footwearColor: suggestion.footwear?.color.color,
                    accessoryColor: suggestion.accessories.first?.color.color
                )
                .frame(height: 500)
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                
                // Footer
                HStack {
                    Text("Slaying today's vibe ✨")
                        .font(.headline.italic())
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("@StyleMateApp")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .frame(width: 400, height: 700)
    }
    
    private func image(for item: WardrobeItem?) -> UIImage? {
        guard let filename = item?.photoFilename else { return nil }
        return wardrobeVM.loadPhoto(filename: filename)
    }
}
