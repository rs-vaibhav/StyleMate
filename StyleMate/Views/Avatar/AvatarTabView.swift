import SwiftUI
import PhotosUI

struct AvatarTabView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @ObservedObject var outfitVM: OutfitViewModel
    
    // Selected wardrobe items for try-on
    @State private var selectedTop: WardrobeItem?
    @State private var selectedBottom: WardrobeItem?
    @State private var selectedFootwear: WardrobeItem?
    @State private var selectedAccessory: WardrobeItem?
    
    private var today: Date { Date() }
    
    private var luckyColors: [AppColor] {
        AstrologyEngine.luckyColors(for: today, zodiac: profileVM.profile.zodiacSign)
    }
    
    // Load images for selected wardrobe items
    private var topImage: UIImage? {
        guard let fn = selectedTop?.photoFilename else { return nil }
        return wardrobeVM.loadPhoto(filename: fn)
    }
    
    private var bottomImage: UIImage? {
        guard let fn = selectedBottom?.photoFilename else { return nil }
        return wardrobeVM.loadPhoto(filename: fn)
    }
    
    private var footwearImage: UIImage? {
        guard let fn = selectedFootwear?.photoFilename else { return nil }
        return wardrobeVM.loadPhoto(filename: fn)
    }
    
    private var matchScore: Int {
        StyleMatchEngine.matchScore(
            top: selectedTop?.color, bottom: selectedBottom?.color,
            footwear: selectedFootwear?.color, accessory: selectedAccessory?.color,
            luckyColors: luckyColors
        )
    }
    
    private var harmonyLabel: String {
        guard let t = selectedTop?.color, let b = selectedBottom?.color else { return "" }
        return StyleMatchEngine.harmonyLabel(t, b)
    }
    
    private var shoppingSuggestions: [ShoppingSuggestion] {
        StyleMatchEngine.wardrobeGaps(items: wardrobeVM.items, luckyColors: luckyColors)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Text("Virtual Fitting Room")
                        .font(.title.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Mix & match your real wardrobe")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.top, 16)
                
                // 3D Body View
                avatar3DSection
                
                // Wardrobe Item Picker
                if !wardrobeVM.items.isEmpty {
                    wardrobePickerSection
                } else {
                    emptyWardrobePrompt
                }
                
                
                // Shopping Suggestions
                if !shoppingSuggestions.isEmpty {
                    ShoppingSuggestionsView(suggestions: shoppingSuggestions)
                }
                
                // Lucky Colors Today
                luckyColorsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            autoSelectOutfit()
        }
    }
    
    // MARK: - Auto Select
    
    private func autoSelectOutfit() {
        if selectedTop == nil, let first = wardrobeVM.items(for: .top).first {
            selectedTop = first
        }
        if selectedBottom == nil, let first = wardrobeVM.items(for: .bottom).first {
            selectedBottom = first
        }
        if selectedFootwear == nil, let first = wardrobeVM.items(for: .footwear).first {
            selectedFootwear = first
        }
        if selectedAccessory == nil, let first = wardrobeVM.items(for: .accessory).first {
            selectedAccessory = first
        }
    }
    
    // MARK: - 3D Avatar Section
    
    private var avatar3DSection: some View {
        VStack(spacing: 12) {
            outfitPillsBar
            
            OutfitBoardView(
                topImage: topImage,
                bottomImage: bottomImage,
                footwearImage: footwearImage,
                topColor: selectedTop?.color.color,
                bottomColor: selectedBottom?.color.color,
                footwearColor: selectedFootwear?.color.color,
                accessoryColor: selectedAccessory?.color.color
            )
            .frame(height: 440)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            
            HStack(spacing: 12) {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    shuffleOutfit()
                } label: {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Shuffle Outfit")
                    }
                    .font(.callout.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Theme.shadowLight, radius: 4, y: 2)
                }
                
                if !harmonyLabel.isEmpty {
                    Text(harmonyLabel)
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Theme.shadowLight, radius: 4, y: 2)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private var outfitPillsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let top = selectedTop {
                    outfitPill(icon: "tshirt.fill", name: top.name, color: top.color)
                }
                if let bottom = selectedBottom {
                    outfitPill(icon: "rectangle.split.1x2.fill", name: bottom.name, color: bottom.color)
                }
                if let foot = selectedFootwear {
                    outfitPill(icon: "shoeprints.fill", name: foot.name, color: foot.color)
                }
                if let acc = selectedAccessory {
                    outfitPill(icon: "sparkles", name: acc.name, color: acc.color)
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func outfitPill(icon: String, name: String, color: AppColor) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color.color)
                .frame(width: 12, height: 12)
            Text(name)
                .font(.caption2.weight(.medium))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.color.opacity(0.10))
        .clipShape(Capsule())
    }
    
    // MARK: - Wardrobe Item Picker
    
    private var wardrobePickerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "tshirt.fill")
                    .foregroundColor(Theme.accentRed)
                Text("Try On Your Wardrobe")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("Tap to try")
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
            }
            
            // Category rows
            categoryPickerRow(
                category: .top,
                selected: $selectedTop,
                accentColor: Theme.accentRed
            )
            
            categoryPickerRow(
                category: .bottom,
                selected: $selectedBottom,
                accentColor: Theme.accentBlue
            )
            
            categoryPickerRow(
                category: .footwear,
                selected: $selectedFootwear,
                accentColor: Theme.accentGreen
            )
            
            categoryPickerRow(
                category: .accessory,
                selected: $selectedAccessory,
                accentColor: Theme.accentYellow
            )
        }
        .padding(16)
        .glassCard()
    }
    
    private func categoryPickerRow(
        category: ClothingCategory,
        selected: Binding<WardrobeItem?>,
        accentColor: Color
    ) -> some View {
        let items = wardrobeVM.items(for: category)
        
        return Group {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundColor(accentColor)
                        Text(category.rawValue + "s")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Theme.textPrimary)
                        
                        Spacer()
                        
                        if selected.wrappedValue != nil {
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selected.wrappedValue = nil
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(items) { item in
                                tryOnItemCard(item, isSelected: selected.wrappedValue?.id == item.id) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        selected.wrappedValue = item
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func tryOnItemCard(_ item: WardrobeItem, isSelected: Bool, action: @escaping () -> Void) -> some View {
        let isLucky = luckyColors.contains(item.color)
        
        return Button(action: action) {
            VStack(spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    if let filename = item.photoFilename,
                       let image = wardrobeVM.loadPhoto(filename: filename) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(item.color.color.opacity(0.3))
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: item.category.icon)
                                    .font(.title3)
                                    .foregroundColor(item.color.color)
                            )
                    }
                    
                    if isLucky {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.accentYellow)
                            .padding(3)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .offset(x: 3, y: -3)
                    }
                }
                
                Text(item.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                    .frame(width: 72)
            }
            .padding(5)
            .background(isSelected ? Theme.accentBlue.opacity(0.08) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.accentBlue : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
    
    // MARK: - Empty Wardrobe
    
    private var emptyWardrobePrompt: some View {
        VStack(spacing: 14) {
            Image(systemName: "hanger")
                .font(.system(size: 40))
                .foregroundColor(Theme.textMuted)
            
            Text("Add clothes to try on")
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            Text("Go to Wardrobe tab and add your real fits\nwith photos to see them on your 3D model")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassCard()
    }
    
    // MARK: - Lucky Colors
    
    private var luckyColorsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            let planet = AstrologyEngine.rulingPlanet(for: today)
            
            HStack(spacing: 6) {
                Text(planet.symbol)
                    .font(.title3)
                Text("Today's Lucky Colors")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(planet.name)
                    .font(.caption.weight(.medium))
                    .foregroundColor(Theme.textSecondary)
            }
            
            HStack(spacing: 10) {
                ForEach(Array(luckyColors.prefix(6)), id: \.self) { color in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: color.color.opacity(0.3), radius: 4)
                        
                        Text(color.displayName)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - Shuffle
    
    private func shuffleOutfit() {
        let tops = wardrobeVM.items(for: .top)
        let bottoms = wardrobeVM.items(for: .bottom)
        let shoes = wardrobeVM.items(for: .footwear)
        let accessories = wardrobeVM.items(for: .accessory)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            // Smart shuffle: pick a random top, then find best matching pieces
            if let randomTop = tops.randomElement() {
                selectedTop = randomTop
                
                if !bottoms.isEmpty {
                    selectedBottom = StyleMatchEngine.bestBottom(for: randomTop.color, from: bottoms) ?? bottoms.randomElement()
                }
                if !shoes.isEmpty, let bot = selectedBottom {
                    selectedFootwear = StyleMatchEngine.bestFootwear(for: randomTop.color, bottom: bot.color, from: shoes) ?? shoes.randomElement()
                }
                if let random = accessories.randomElement() { selectedAccessory = random }
            }
        }
    }
    
    // MARK: - Style Harmony Card
    
    private var styleHarmonyCard: some View {
        HStack(spacing: 12) {
            // Color harmony visual
            if let topC = selectedTop?.color, let botC = selectedBottom?.color {
                HStack(spacing: -6) {
                    Circle()
                        .fill(topC.color)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    Circle()
                        .fill(botC.color)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    if let fc = selectedFootwear?.color {
                        Circle()
                            .fill(fc.color)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                .shadow(color: .black.opacity(0.08), radius: 4)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(harmonyLabel)
                    .font(.callout.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                
                Text("Color theory match")
                    .font(.caption2)
                    .foregroundColor(Theme.textMuted)
            }
            
            Spacer()
            
            // Score badge
            VStack(spacing: 2) {
                Text("\(matchScore)")
                    .font(.title2.weight(.black))
                    .foregroundColor(matchScore > 70 ? Theme.accentGreen : matchScore > 40 ? Theme.accentOrange : Theme.accentRed)
                Text("score")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Theme.textMuted)
            }
            .frame(width: 50)
        }
        .padding(14)
        .glassCard()
    }
}
