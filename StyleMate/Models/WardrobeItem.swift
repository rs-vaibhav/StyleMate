import Foundation
import SwiftUI

// MARK: - Clothing Category

enum ClothingCategory: String, CaseIterable, Codable {
    case top = "Top"
    case bottom = "Bottom"
    case footwear = "Footwear"
    case accessory = "Accessory"
    
    var icon: String {
        switch self {
        case .top: return "tshirt.fill"
        case .bottom: return "rectangle.split.1x2.fill"
        case .footwear: return "shoeprints.fill"
        case .accessory: return "sparkles"
        }
    }
    
    var examples: String {
        switch self {
        case .top: return "T-Shirts, Shirts, Kurtas, Jackets"
        case .bottom: return "Jeans, Trousers, Shorts, Chinos"
        case .footwear: return "Sneakers, Formal Shoes, Sandals"
        case .accessory: return "Watch, Sunglasses, Belt, Cap"
        }
    }
}

// MARK: - Occasion

enum Occasion: String, CaseIterable, Codable {
    case casual = "Casual"
    case formal = "Formal"
    case party = "Party"
    case gym = "Gym"
    
    var icon: String {
        switch self {
        case .casual: return "cup.and.saucer.fill"
        case .formal: return "briefcase.fill"
        case .party: return "party.popper.fill"
        case .gym: return "dumbbell.fill"
        }
    }
}

// MARK: - App Color

enum AppColor: String, CaseIterable, Codable, Identifiable {
    case white, cream, silver
    case red, coral, maroon
    case orange, saffron
    case yellow, gold, mustard
    case green, emerald, teal, mint
    case lightBlue, blue, navy
    case lavender, purple
    case pink, rose
    case black, grey, brown, beige, khaki
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .white: return Color(red: 1.0, green: 1.0, blue: 1.0)
        case .cream: return Color(red: 1.0, green: 0.99, blue: 0.82)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .red: return Color(red: 0.9, green: 0.15, blue: 0.15)
        case .coral: return Color(red: 1.0, green: 0.5, blue: 0.31)
        case .maroon: return Color(red: 0.5, green: 0.0, blue: 0.0)
        case .orange: return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .saffron: return Color(red: 0.96, green: 0.77, blue: 0.19)
        case .yellow: return Color(red: 1.0, green: 0.92, blue: 0.23)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .mustard: return Color(red: 0.9, green: 0.8, blue: 0.2)
        case .green: return Color(red: 0.18, green: 0.7, blue: 0.3)
        case .emerald: return Color(red: 0.31, green: 0.78, blue: 0.47)
        case .teal: return Color(red: 0.0, green: 0.5, blue: 0.5)
        case .mint: return Color(red: 0.6, green: 0.9, blue: 0.75)
        case .lightBlue: return Color(red: 0.68, green: 0.85, blue: 0.9)
        case .blue: return Color(red: 0.2, green: 0.4, blue: 0.9)
        case .navy: return Color(red: 0.0, green: 0.0, blue: 0.5)
        case .lavender: return Color(red: 0.73, green: 0.59, blue: 0.89)
        case .purple: return Color(red: 0.5, green: 0.0, blue: 0.5)
        case .pink: return Color(red: 1.0, green: 0.41, blue: 0.71)
        case .rose: return Color(red: 1.0, green: 0.0, blue: 0.5)
        case .black: return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .grey: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .brown: return Color(red: 0.55, green: 0.27, blue: 0.07)
        case .beige: return Color(red: 0.96, green: 0.96, blue: 0.86)
        case .khaki: return Color(red: 0.76, green: 0.69, blue: 0.57)
        }
    }
    
    var displayName: String {
        switch self {
        case .lightBlue: return "Light Blue"
        default:
            return rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }
    
    var needsDarkText: Bool {
        switch self {
        case .white, .cream, .silver, .yellow, .gold, .mustard, .mint, .lightBlue, .beige, .khaki, .pink:
            return true
        default:
            return false
        }
    }
}

// MARK: - Wardrobe Item

struct WardrobeItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var category: ClothingCategory
    var color: AppColor
    var occasion: Occasion
    var photoFilename: String?
    var dateAdded: Date = Date()
    
    static func == (lhs: WardrobeItem, rhs: WardrobeItem) -> Bool {
        lhs.id == rhs.id
    }
}
