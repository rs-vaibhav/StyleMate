import SwiftUI

struct HomeView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @ObservedObject var outfitVM: OutfitViewModel
    
    @State private var showConfirmation = false
    
    private var today: Date { Date() }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Hero Header
                heroHeader
                
                // Lucky Colors
                LuckyColorBanner(
                    colors: AstrologyEngine.luckyColors(for: today, zodiac: profileVM.profile.zodiacSign),
                    planet: AstrologyEngine.rulingPlanet(for: today)
                )
                .padding(.horizontal, 16)
                
                // Outfit Suggestion
                if wardrobeVM.items.isEmpty {
                    emptyWardrobeCard
                } else {
                    outfitCard
                    
                    // Action Buttons
                    actionButtons
                }
                
                // Daily Tip
                tipCard
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            if outfitVM.currentSuggestion == nil && !wardrobeVM.items.isEmpty {
                outfitVM.generateSuggestion(
                    for: today,
                    profile: profileVM.profile,
                    wardrobe: wardrobeVM.items
                )
            }
        }
    }
    
    // MARK: - Hero Header
    
    private var heroHeader: some View {
        VStack(spacing: 8) {
            Text(today.dayOfWeekName.uppercased())
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.8, green: 0.6, blue: 1.0),
                            Color(red: 0.5, green: 0.3, blue: 0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shimmer()
            
            Text(AstrologyEngine.formattedDate(today))
                .font(.callout.weight(.medium))
                .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 6) {
                Text(profileVM.profile.zodiacSign.symbol)
                Text(profileVM.profile.zodiacSign.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
        .padding(.top, 16)
    }
    
    // MARK: - Empty Wardrobe
    
    private var emptyWardrobeCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "hanger")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Your Wardrobe is Empty")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
            
            Text("Add your clothes, shoes, and accessories\nto get personalized outfit suggestions")
                .font(.callout)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            Text("Go to the Wardrobe tab to start adding items →")
                .font(.caption.weight(.medium))
                .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.9))
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Outfit Card
    
    private var outfitCard: some View {
        VStack(spacing: 16) {
            Text("Today's Outfit")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
            
            if let suggestion = outfitVM.currentSuggestion {
                // Body Silhouette
                BodySilhouetteView(
                    topColor: suggestion.top?.color.color ?? Color.gray.opacity(0.3),
                    bottomColor: suggestion.bottom?.color.color ?? Color.gray.opacity(0.3),
                    footwearColor: suggestion.footwear?.color.color ?? Color.gray.opacity(0.3),
                    accessoryColor: suggestion.accessories.first?.color.color
                )
                .padding(.vertical, 8)
                
                // Outfit Details
                VStack(spacing: 10) {
                    if let top = suggestion.top {
                        outfitItemRow(icon: "tshirt.fill", name: top.name, color: top.color)
                    }
                    if let bottom = suggestion.bottom {
                        outfitItemRow(icon: "rectangle.split.1x2.fill", name: bottom.name, color: bottom.color)
                    }
                    if let footwear = suggestion.footwear {
                        outfitItemRow(icon: "shoeprints.fill", name: footwear.name, color: footwear.color)
                    }
                    ForEach(suggestion.accessories) { acc in
                        outfitItemRow(icon: "sparkles", name: acc.name, color: acc.color)
                    }
                }
                
                // Match Score
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Lucky Match: \(suggestion.matchScore)%")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(suggestion.matchScore > 50 ? .green : .orange)
                }
                .padding(.top, 8)
                
                if suggestion.confirmed {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Outfit Confirmed!")
                            .font(.callout.weight(.medium))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    private func outfitItemRow(icon: String, name: String, color: AppColor) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 24)
            
            Text(name)
                .font(.callout)
                .foregroundColor(.white)
            
            Spacer()
            
            Circle()
                .fill(color.color)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            Text(color.displayName)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button {
                outfitVM.shuffleSuggestion(
                    for: today,
                    profile: profileVM.profile,
                    wardrobe: wardrobeVM.items
                )
            } label: {
                HStack {
                    Image(systemName: "shuffle")
                    Text("Shuffle")
                }
                .font(.callout.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button {
                outfitVM.confirmOutfit()
                showConfirmation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showConfirmation = false
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Wear This!")
                }
                .font(.callout.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(LinearGradient.cosmicAccent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color(red: 0.5, green: 0.2, blue: 0.9).opacity(0.4), radius: 8, y: 3)
            }
            .disabled(outfitVM.currentSuggestion?.confirmed ?? false)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Tip Card
    
    private var tipCard: some View {
        HStack(spacing: 12) {
            Text("✨")
                .font(.title2)
            
            Text(AstrologyEngine.dailyTip(for: today, zodiac: profileVM.profile.zodiacSign))
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .padding(.horizontal, 16)
    }
}
