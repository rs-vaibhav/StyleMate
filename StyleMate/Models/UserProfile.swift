import Foundation

// MARK: - Enums

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-Binary"
    
    var icon: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        case .nonBinary: return "figure.wave"
        }
    }
}

enum SkinTone: String, CaseIterable, Codable {
    case light = "Light"
    case medium = "Medium"
    case tan = "Tan"
    case dark = "Dark"
    
    var emoji: String {
        switch self {
        case .light: return "🏻"
        case .medium: return "🏼"
        case .tan: return "🏽"
        case .dark: return "🏿"
        }
    }
}

enum BodyType: String, CaseIterable, Codable {
    case slim = "Slim"
    case athletic = "Athletic"
    case average = "Average"
    case heavy = "Heavy"
}

enum ZodiacSign: String, CaseIterable, Codable {
    case aries = "Aries"
    case taurus = "Taurus"
    case gemini = "Gemini"
    case cancer = "Cancer"
    case leo = "Leo"
    case virgo = "Virgo"
    case libra = "Libra"
    case scorpio = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn = "Capricorn"
    case aquarius = "Aquarius"
    case pisces = "Pisces"
    
    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }
    
    var element: String {
        switch self {
        case .aries, .leo, .sagittarius: return "🔥 Fire"
        case .taurus, .virgo, .capricorn: return "🌍 Earth"
        case .gemini, .libra, .aquarius: return "💨 Air"
        case .cancer, .scorpio, .pisces: return "🌊 Water"
        }
    }
    
    static func from(month: Int, day: Int) -> ZodiacSign {
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return .aries
        case (4, 20...30), (5, 1...20): return .taurus
        case (5, 21...31), (6, 1...20): return .gemini
        case (6, 21...30), (7, 1...22): return .cancer
        case (7, 23...31), (8, 1...22): return .leo
        case (8, 23...31), (9, 1...22): return .virgo
        case (9, 23...30), (10, 1...22): return .libra
        case (10, 23...31), (11, 1...21): return .scorpio
        case (11, 22...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...19): return .capricorn
        case (1, 20...31), (2, 1...18): return .aquarius
        case (2, 19...29), (3, 1...20): return .pisces
        default: return .aries
        }
    }
}

// MARK: - User Profile

struct UserProfile: Codable, Equatable {
    var name: String = ""
    var dateOfBirth: Date = Date()
    var gender: Gender = .male
    var skinTone: SkinTone = .medium
    var bodyType: BodyType = .average
    
    var zodiacSign: ZodiacSign {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: dateOfBirth)
        let day = calendar.component(.day, from: dateOfBirth)
        return ZodiacSign.from(month: month, day: day)
    }
    
    var isComplete: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
