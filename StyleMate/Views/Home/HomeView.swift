import SwiftUI

struct HomeView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @ObservedObject var outfitVM: OutfitViewModel
    
    @State private var showConfirmation = false
    @State private var showProfileSettings = false
    
    private var today: Date { Date() }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Top Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hey, \(profileVM.profile.name) 👋")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        Text("Let's find your look today")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showProfileSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
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
        .sheet(isPresented: $showProfileSettings) {
            ProfileSettingsView(profileVM: profileVM)
        }
    }
    
    // MARK: - Hero Header
    
    private var heroHeader: some View {
        VStack(spacing: 8) {
            Text(today.dayOfWeekName.uppercased())
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient.vibrantHero
                )
                .shadow(color: Theme.accentRed.opacity(0.3), radius: 10, x: 0, y: 5)
                .shimmer()
            
            Text(AstrologyEngine.formattedDate(today))
                .font(.callout.weight(.medium))
                .foregroundColor(Theme.textSecondary)
            
            HStack(spacing: 6) {
                Text(profileVM.profile.zodiacSign.symbol)
                Text(profileVM.profile.zodiacSign.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.accentPurple)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.accentPurple.opacity(0.08))
            .clipShape(Capsule())
        }
        .padding(.top, 8)
    }
    
    // MARK: - Empty Wardrobe
    
    private var emptyWardrobeCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "hanger")
                .font(.system(size: 50))
                .foregroundColor(Theme.textMuted)
            
            Text("Your Wardrobe is Empty 🥲")
                .font(.title2.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            Text("Add your fav fits, kicks, and accessories\nto get lit outfit suggestions 🔥")
                .font(.callout.weight(.medium))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("Tap Wardrobe to start styling ✨")
                .font(.callout.weight(.bold))
                .foregroundColor(Theme.accentRed)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Outfit Card
    
    private var outfitCard: some View {
        VStack(spacing: 16) {
            Text("Today's Fit Drop 💧")
                .font(.title3.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            if let suggestion = outfitVM.currentSuggestion {
                // Outfit photo grid — actual clothing photos
                outfitPhotoGrid(suggestion)
                
                // Outfit Details with thumbnails
                VStack(spacing: 10) {
                    if let top = suggestion.top {
                        outfitItemRow(item: top, icon: "tshirt.fill")
                    }
                    if let bottom = suggestion.bottom {
                        outfitItemRow(item: bottom, icon: "rectangle.split.1x2.fill")
                    }
                    if let footwear = suggestion.footwear {
                        outfitItemRow(item: footwear, icon: "shoeprints.fill")
                    }
                    ForEach(suggestion.accessories) { acc in
                        outfitItemRow(item: acc, icon: "sparkles")
                    }
                }
                
                // Match Score
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Theme.accentYellow)
                        .shadow(color: Theme.accentYellow, radius: 5)
                    Text("Vibe Match: \(suggestion.matchScore)%")
                        .font(.callout.weight(.bold))
                        .foregroundColor(suggestion.matchScore > 50 ? Theme.accentGreen : Theme.accentOrange)
                }
                .padding(.top, 8)
                
                if suggestion.confirmed {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.accentGreen)
                        Text("Outfit Confirmed!")
                            .font(.callout.weight(.medium))
                            .foregroundColor(Theme.accentGreen)
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
    
    private func outfitPhotoGrid(_ suggestion: OutfitSuggestion) -> some View {
        let allItems = suggestion.allItems
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(allItems) { item in
                    VStack(spacing: 6) {
                        if let fn = item.photoFilename,
                           let image = wardrobeVM.loadPhoto(filename: fn) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Theme.shadowMedium, radius: 4, y: 2)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(item.color.color.opacity(0.3))
                                .frame(width: 80, height: 100)
                                .overlay(
                                    Image(systemName: item.category.icon)
                                        .font(.title3)
                                        .foregroundColor(item.color.color)
                                )
                        }
                        
                        Text(item.category.rawValue)
                            .font(.caption2.weight(.medium))
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 4)
    }
    
    private func outfitItemRow(item: WardrobeItem, icon: String) -> some View {
        HStack(spacing: 12) {
            if let fn = item.photoFilename,
               let image = wardrobeVM.loadPhoto(filename: fn) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(Theme.textMuted)
                    .frame(width: 36, height: 36)
                    .background(item.color.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Text(item.name)
                .font(.callout)
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            Circle()
                .fill(item.color.color)
                .frame(width: 16, height: 16)
                .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
            
            Text(item.color.displayName)
                .font(.caption)
                .foregroundColor(Theme.textMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
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
                .foregroundColor(Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Theme.shadowLight, radius: 6, x: 0, y: 3)
            }
            
            Button {
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
                outfitVM.confirmOutfit()
                showConfirmation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showConfirmation = false
                }
            } label: {
                HStack {
                    Text("Slay This! 💅")
                }
                .font(.callout.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient.vibrantAccent
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Theme.accentRed.opacity(0.4), radius: 10, y: 5)
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
                .foregroundColor(Theme.textSecondary)
                .lineLimit(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .padding(.horizontal, 16)
    }
}
