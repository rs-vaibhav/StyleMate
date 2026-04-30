import Foundation

struct OutfitSuggestion: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var top: WardrobeItem?
    var bottom: WardrobeItem?
    var footwear: WardrobeItem?
    var accessories: [WardrobeItem]
    var luckyColors: [AppColor]
    var confirmed: Bool = false
    
    var isComplete: Bool {
        top != nil && bottom != nil
    }
    
    var allItems: [WardrobeItem] {
        var items: [WardrobeItem] = []
        if let top = top { items.append(top) }
        if let bottom = bottom { items.append(bottom) }
        if let footwear = footwear { items.append(footwear) }
        items.append(contentsOf: accessories)
        return items
    }
    
    var matchScore: Int {
        var score = 0
        for item in allItems {
            if luckyColors.contains(item.color) {
                score += 25
            }
        }
        return min(score, 100)
    }
}
