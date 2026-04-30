import Foundation

struct AstrologyEngine {
    
    // MARK: - Day Lucky Colors (Vedic Astrology)
    
    static func dayLuckyColors(for date: Date) -> [AppColor] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return [.orange, .gold, .red, .saffron]       // Sunday - Sun
        case 2: return [.white, .silver, .cream, .lightBlue]   // Monday - Moon
        case 3: return [.red, .orange, .coral, .maroon]        // Tuesday - Mars
        case 4: return [.green, .emerald, .teal, .mint]        // Wednesday - Mercury
        case 5: return [.yellow, .gold, .mustard, .orange]     // Thursday - Jupiter
        case 6: return [.pink, .lightBlue, .lavender, .white]  // Friday - Venus
        case 7: return [.black, .navy, .blue, .grey]           // Saturday - Saturn
        default: return [.white]
        }
    }
    
    static func rulingPlanet(for date: Date) -> (name: String, symbol: String) {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return ("Sun", "☀️")
        case 2: return ("Moon", "🌙")
        case 3: return ("Mars", "♂️")
        case 4: return ("Mercury", "☿️")
        case 5: return ("Jupiter", "♃")
        case 6: return ("Venus", "♀️")
        case 7: return ("Saturn", "♄")
        default: return ("Sun", "☀️")
        }
    }
    
    // MARK: - Zodiac Lucky Colors
    
    static func zodiacLuckyColors(for sign: ZodiacSign) -> [AppColor] {
        switch sign {
        case .aries: return [.red, .coral, .orange, .white]
        case .taurus: return [.green, .pink, .cream, .white]
        case .gemini: return [.yellow, .green, .lightBlue, .orange]
        case .cancer: return [.white, .silver, .cream, .lightBlue]
        case .leo: return [.gold, .orange, .red, .yellow]
        case .virgo: return [.green, .brown, .cream, .navy]
        case .libra: return [.pink, .lightBlue, .lavender, .white]
        case .scorpio: return [.maroon, .red, .black, .purple]
        case .sagittarius: return [.purple, .blue, .orange, .yellow]
        case .capricorn: return [.brown, .black, .grey, .navy]
        case .aquarius: return [.blue, .lightBlue, .teal, .purple]
        case .pisces: return [.lavender, .lightBlue, .green, .silver]
        }
    }
    
    // MARK: - Combined Lucky Colors
    
    static func luckyColors(for date: Date, zodiac: ZodiacSign) -> [AppColor] {
        let dayColors = dayLuckyColors(for: date)
        let zodiacColors = zodiacLuckyColors(for: zodiac)
        
        // Priority: colors appearing in BOTH lists first, then day colors, then zodiac
        var combined: [AppColor] = []
        for color in dayColors where zodiacColors.contains(color) {
            if !combined.contains(color) { combined.append(color) }
        }
        for color in dayColors {
            if !combined.contains(color) { combined.append(color) }
        }
        for color in zodiacColors {
            if !combined.contains(color) { combined.append(color) }
        }
        return combined
    }
    
    // MARK: - Outfit Suggestion
    
    static func suggestOutfit(
        for date: Date,
        profile: UserProfile,
        wardrobe: [WardrobeItem],
        excluding: [UUID] = []
    ) -> OutfitSuggestion {
        let lucky = luckyColors(for: date, zodiac: profile.zodiacSign)
        
        let availableTops = wardrobe.filter { $0.category == .top && !excluding.contains($0.id) }
        let availableBottoms = wardrobe.filter { $0.category == .bottom && !excluding.contains($0.id) }
        let availableFootwear = wardrobe.filter { $0.category == .footwear && !excluding.contains($0.id) }
        let availableAccessories = wardrobe.filter { $0.category == .accessory && !excluding.contains($0.id) }
        
        // Score each item by how well it matches lucky colors
        func scored(_ items: [WardrobeItem]) -> [WardrobeItem] {
            return items.sorted { a, b in
                let aScore = lucky.firstIndex(of: a.color) ?? 999
                let bScore = lucky.firstIndex(of: b.color) ?? 999
                return aScore < bScore
            }
        }
        
        let sortedTops = scored(availableTops)
        let sortedBottoms = scored(availableBottoms)
        let sortedFootwear = scored(availableFootwear)
        let sortedAccessories = scored(availableAccessories)
        
        // Pick the best match, or random if no lucky match
        let top = sortedTops.first
        let bottom = sortedBottoms.first
        let footwear = sortedFootwear.first
        let accessories = Array(sortedAccessories.prefix(2))
        
        return OutfitSuggestion(
            date: date,
            top: top,
            bottom: bottom,
            footwear: footwear,
            accessories: accessories,
            luckyColors: lucky
        )
    }
    
    // MARK: - Day Info
    
    static func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Daily Tip
    
    static func dailyTip(for date: Date, zodiac: ZodiacSign) -> String {
        let planet = rulingPlanet(for: date)
        let tips: [String] = [
            "\(planet.symbol) \(planet.name) governs today. Wearing \(dayLuckyColors(for: date).prefix(2).map(\.displayName).joined(separator: " or ")) will amplify your confidence!",
            "As a \(zodiac.rawValue) (\(zodiac.element)), you radiate best in colors that align with \(planet.name)'s energy today.",
            "\(planet.symbol) Today's planetary ruler \(planet.name) suggests bold choices. Trust the cosmic palette!",
            "Your \(zodiac.element) energy harmonizes beautifully with \(planet.name)'s influence today.",
        ]
        let dayIndex = Calendar.current.component(.weekday, from: date)
        return tips[dayIndex % tips.count]
    }
}
