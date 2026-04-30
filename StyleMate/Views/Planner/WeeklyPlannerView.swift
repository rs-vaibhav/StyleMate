import SwiftUI

struct WeeklyPlannerView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @ObservedObject var outfitVM: OutfitViewModel
    
    @State private var selectedDate: Date? = nil
    
    private var weekDates: [Date] {
        Date.currentWeekDates()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Weekly Planner")
                        .font(.title.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("Plan your outfits for the week")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 16)
                
                // Week Cards
                ForEach(weekDates, id: \.self) { date in
                    weekDayCard(date: date)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Day Card
    
    private func weekDayCard(date: Date) -> some View {
        let luckyColors = AstrologyEngine.dayLuckyColors(for: date)
        let planet = AstrologyEngine.rulingPlanet(for: date)
        let outfit = outfitVM.outfit(for: date)
        let isToday = date.isToday
        
        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(date.dayOfWeekName)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                        
                        if isToday {
                            Text("TODAY")
                                .font(.caption2.weight(.heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient.cosmicAccent
                                )
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(planet.symbol)
                            .font(.caption)
                        Text(planet.name)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        Text("•")
                            .foregroundColor(.white.opacity(0.3))
                        Text("\(date.dayNumber) \(date.monthName)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Lucky color dots
                HStack(spacing: 4) {
                    ForEach(Array(luckyColors.prefix(4)), id: \.self) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            
            if let outfit = outfit {
                // Show confirmed outfit
                HStack(spacing: 8) {
                    if let top = outfit.top {
                        miniItemPill(name: top.name, color: top.color)
                    }
                    if let bottom = outfit.bottom {
                        miniItemPill(name: bottom.name, color: bottom.color)
                    }
                    if let foot = outfit.footwear {
                        miniItemPill(name: foot.name, color: foot.color)
                    }
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Outfit set!")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.8))
                }
            } else if !wardrobeVM.items.isEmpty {
                Button {
                    outfitVM.generateSuggestion(
                        for: date,
                        profile: profileVM.profile,
                        wardrobe: wardrobeVM.items
                    )
                    outfitVM.confirmOutfit()
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Auto-suggest")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isToday ? Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
    }
    
    private func miniItemPill(name: String, color: AppColor) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color.color)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }
}
