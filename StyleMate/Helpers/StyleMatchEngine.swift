import SwiftUI

/// Advanced outfit matching engine using color theory, style rules, and seasonal trends.
struct StyleMatchEngine {
    
    // MARK: - Color Theory Matching
    
    /// Returns a comprehensive match score (0-100) for an outfit combination
    static func matchScore(
        top: AppColor?, bottom: AppColor?, footwear: AppColor?, accessory: AppColor?,
        luckyColors: [AppColor]
    ) -> Int {
        var score: Double = 0
        var factors: Double = 0
        
        // Factor 1: Color harmony between top & bottom (weight: 40%)
        if let t = top, let b = bottom {
            score += colorHarmony(t, b) * 40
            factors += 40
        }
        
        // Factor 2: Footwear coordination (weight: 20%)
        if let t = top, let f = footwear {
            score += colorHarmony(t, f) * 20
            factors += 20
        }
        if let b = bottom, let f = footwear {
            score += colorHarmony(b, f) * 20
            factors += 20
        }
        
        // Factor 3: Lucky color bonus (weight: 20%)
        let items = [top, bottom, footwear, accessory].compactMap { $0 }
        if !items.isEmpty && !luckyColors.isEmpty {
            let luckyMatches = items.filter { luckyColors.contains($0) }.count
            let luckyScore = Double(luckyMatches) / Double(items.count)
            score += luckyScore * 20
            factors += 20
        }
        
        // Factor 4: Neutral balance (weight: 10%)
        let neutrals: Set<AppColor> = [.black, .white, .grey, .cream, .silver, .navy]
        let neutralCount = items.filter { neutrals.contains($0) }.count
        let colorCount = items.count - neutralCount
        if items.count >= 2 {
            // Good balance: at least one neutral + one color
            let balanceScore = (neutralCount >= 1 && colorCount >= 1) ? 1.0 :
                               (neutralCount == items.count) ? 0.7 : 0.5
            score += balanceScore * 10
            factors += 10
        }
        
        guard factors > 0 else { return 50 }
        return min(100, Int(score / factors * 100))
    }
    
    /// Color harmony score (0.0 - 1.0) between two colors
    static func colorHarmony(_ a: AppColor, _ b: AppColor) -> Double {
        let rel = relationship(a, b)
        switch rel {
        case .same: return 0.6
        case .complementary: return 1.0
        case .analogous: return 0.85
        case .triadic: return 0.9
        case .neutral: return 0.75
        case .clash: return 0.3
        case .monochrome: return 0.8
        }
    }
    
    enum ColorRelationship {
        case same, complementary, analogous, triadic, neutral, clash, monochrome
    }
    
    static func relationship(_ a: AppColor, _ b: AppColor) -> ColorRelationship {
        if a == b { return .same }
        
        let neutrals: Set<AppColor> = [.black, .white, .grey, .cream, .silver, .navy, .khaki, .brown]
        if neutrals.contains(a) || neutrals.contains(b) { return .neutral }
        
        // Complementary pairs
        let compPairs: Set<Set<AppColor>> = [
            [.red, .green], [.blue, .orange], [.purple, .yellow],
            [.teal, .coral], [.navy, .gold], [.pink, .emerald],
            [.maroon, .mint], [.lavender, .saffron]
        ]
        if compPairs.contains([a, b]) { return .complementary }
        
        // Analogous groups (neighboring on color wheel)
        let analogousGroups: [[AppColor]] = [
            [.red, .orange, .coral, .saffron],
            [.orange, .yellow, .gold, .cream],
            [.yellow, .green, .mustard, .mint],
            [.green, .teal, .emerald, .mint],
            [.blue, .teal, .navy, .lightBlue],
            [.blue, .purple, .lavender, .navy],
            [.purple, .pink, .rose, .lavender],
            [.red, .pink, .coral, .rose],
        ]
        for group in analogousGroups {
            if group.contains(a) && group.contains(b) { return .analogous }
        }
        
        // Monochrome (same hue family, different shades)
        let monoGroups: [[AppColor]] = [
            [.blue, .navy, .lightBlue],
            [.red, .maroon, .coral],
            [.green, .emerald, .mint],
            [.brown, .khaki, .cream],
            [.black, .grey, .silver, .white],
            [.purple, .lavender, .rose],
        ]
        for group in monoGroups {
            if group.contains(a) && group.contains(b) { return .monochrome }
        }
        
        // Triadic
        let triadicGroups: [[AppColor]] = [
            [.red, .yellow, .blue],
            [.orange, .green, .purple],
            [.coral, .mint, .lavender],
        ]
        for group in triadicGroups {
            if group.contains(a) && group.contains(b) { return .triadic }
        }
        
        return .clash
    }
    
    // MARK: - Smart Suggestions
    
    /// Returns the best matching bottom for a given top from the wardrobe
    static func bestBottom(for top: AppColor, from items: [WardrobeItem]) -> WardrobeItem? {
        items.max(by: { colorHarmony(top, $0.color) < colorHarmony(top, $1.color) })
    }
    
    /// Returns best matching footwear
    static func bestFootwear(for top: AppColor, bottom: AppColor, from items: [WardrobeItem]) -> WardrobeItem? {
        items.max(by: {
            let s1 = (colorHarmony(top, $0.color) + colorHarmony(bottom, $0.color)) / 2
            let s2 = (colorHarmony(top, $1.color) + colorHarmony(bottom, $1.color)) / 2
            return s1 < s2
        })
    }
    
    /// Gets the harmony label for display
    static func harmonyLabel(_ a: AppColor, _ b: AppColor) -> String {
        switch relationship(a, b) {
        case .complementary: return "Perfect Match ✨"
        case .analogous: return "Smooth Flow 🎨"
        case .triadic: return "Bold Combo 🔥"
        case .neutral: return "Classic & Safe 👔"
        case .monochrome: return "Tonal 🌊"
        case .same: return "Matching Set"
        case .clash: return "Risky Mix ⚡️"
        }
    }
    
    // MARK: - Shopping Gap Analysis
    
    /// Identifies what colors/categories are missing from the wardrobe
    static func wardrobeGaps(items: [WardrobeItem], luckyColors: [AppColor]) -> [ShoppingSuggestion] {
        var suggestions: [ShoppingSuggestion] = []
        
        let tops = items.filter { $0.category == .top }
        let bottoms = items.filter { $0.category == .bottom }
        let shoes = items.filter { $0.category == .footwear }
        
        // Gap 1: Missing lucky colors
        for color in luckyColors.prefix(3) {
            let hasTop = tops.contains { $0.color == color }
            let hasBottom = bottoms.contains { $0.color == color }
            
            if !hasTop {
                suggestions.append(ShoppingSuggestion(
                    title: "\(color.displayName) Top",
                    reason: "Today's lucky color — boost your vibe ✨",
                    category: .top,
                    color: color,
                    searchQuery: "\(color.displayName) t-shirt men",
                    priority: .high
                ))
            }
            if !hasBottom {
                suggestions.append(ShoppingSuggestion(
                    title: "\(color.displayName) Bottom",
                    reason: "Complete your lucky color outfit",
                    category: .bottom,
                    color: color,
                    searchQuery: "\(color.displayName) pants men",
                    priority: .medium
                ))
            }
        }
        
        // Gap 2: Missing complementary pieces
        for top in tops.prefix(3) {
            let compColors = complementaryColors(for: top.color)
            for comp in compColors {
                let hasMatch = bottoms.contains { $0.color == comp }
                if !hasMatch {
                    suggestions.append(ShoppingSuggestion(
                        title: "\(comp.displayName) Bottom",
                        reason: "Perfect match for your \(top.name) 🎯",
                        category: .bottom,
                        color: comp,
                        searchQuery: "\(comp.displayName) jeans men",
                        priority: .medium
                    ))
                }
            }
        }
        
        // Gap 3: Essential neutrals
        let neutrals: [AppColor] = [.black, .white, .navy]
        for neutral in neutrals {
            if !tops.contains(where: { $0.color == neutral }) {
                suggestions.append(ShoppingSuggestion(
                    title: "\(neutral.displayName) Basic Tee",
                    reason: "Wardrobe essential — goes with everything",
                    category: .top,
                    color: neutral,
                    searchQuery: "\(neutral.displayName) basic t-shirt",
                    priority: .low
                ))
            }
        }
        
        // Gap 4: No footwear
        if shoes.isEmpty {
            suggestions.append(ShoppingSuggestion(
                title: "White Sneakers",
                reason: "Every wardrobe needs clean kicks 👟",
                category: .footwear,
                color: .white,
                searchQuery: "white sneakers men casual",
                priority: .high
            ))
        }
        
        // Deduplicate and limit
        var seen = Set<String>()
        return suggestions.filter { seen.insert($0.title).inserted }.prefix(8).map { $0 }
    }
    
    private static func complementaryColors(for color: AppColor) -> [AppColor] {
        let map: [AppColor: [AppColor]] = [
            .red: [.green, .teal], .blue: [.orange, .coral],
            .green: [.red, .maroon], .yellow: [.purple, .lavender],
            .purple: [.yellow, .gold], .orange: [.blue, .navy],
            .pink: [.emerald, .green], .teal: [.coral, .red],
            .navy: [.gold, .cream], .black: [.white, .cream],
            .white: [.black, .navy], .brown: [.lightBlue, .mint],
        ]
        return map[color] ?? [.black, .white]
    }
}

// MARK: - Shopping Suggestion Model

struct ShoppingSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let reason: String
    let category: ClothingCategory
    let color: AppColor
    let searchQuery: String
    let priority: Priority
    
    enum Priority: Int, Comparable {
        case high = 3, medium = 2, low = 1
        static func < (lhs: Priority, rhs: Priority) -> Bool { lhs.rawValue < rhs.rawValue }
    }
    
    /// Product image from Unsplash (free, no API key needed)
    var imageURL: URL? {
        let q = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://source.unsplash.com/300x260/?\(q)")
    }
    
    var amazonURL: URL? {
        let q = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.amazon.in/s?k=\(q)")
    }
    
    var myntraURL: URL? {
        let q = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.myntra.com/\(q.replacingOccurrences(of: " ", with: "-"))")
    }
}
