import SwiftUI

struct WeeklyPlannerView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @ObservedObject var outfitVM: OutfitViewModel
    
    @State private var selectedDate: Date? = nil
    @State private var previewSuggestion: OutfitSuggestion? = nil
    @State private var showPreview = false
    
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
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Plan your outfits for the week")
                        .font(.callout)
                        .foregroundColor(Theme.textSecondary)
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
        .alert("Confirm Outfit?", isPresented: $showPreview) {
            Button("Confirm") {
                if previewSuggestion != nil {
                    outfitVM.confirmOutfit()
                }
            }
            Button("Shuffle") {
                if let date = selectedDate {
                    outfitVM.shuffleSuggestion(
                        for: date,
                        profile: profileVM.profile,
                        wardrobe: wardrobeVM.items
                    )
                    outfitVM.confirmOutfit()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let suggestion = previewSuggestion {
                let items = [suggestion.top?.name, suggestion.bottom?.name, suggestion.footwear?.name]
                    .compactMap { $0 }
                    .joined(separator: " + ")
                Text("Outfit: \(items)\nVibe Match: \(suggestion.matchScore)%")
            }
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
                            .foregroundColor(Theme.textPrimary)
                        
                        if isToday {
                            Text("TODAY")
                                .font(.caption2.weight(.heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient.vibrantAccent
                                )
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(planet.symbol)
                            .font(.caption)
                        Text(planet.name)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        Text("•")
                            .foregroundColor(Theme.textMuted)
                        Text("\(date.dayNumber) \(date.monthName)")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
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
                        .foregroundColor(Theme.accentGreen)
                        .font(.caption)
                    Text("Outfit set!")
                        .font(.caption)
                        .foregroundColor(Theme.accentGreen)
                }
            } else if !wardrobeVM.items.isEmpty {
                Button {
                    selectedDate = date
                    outfitVM.generateSuggestion(
                        for: date,
                        profile: profileVM.profile,
                        wardrobe: wardrobeVM.items
                    )
                    previewSuggestion = outfitVM.currentSuggestion
                    showPreview = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Auto-suggest")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(Theme.accentGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.accentGreen.opacity(0.10))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isToday ? Theme.accentRed.opacity(0.4) : Color.clear,
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
                .foregroundColor(Theme.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.background)
        .clipShape(Capsule())
    }
}
