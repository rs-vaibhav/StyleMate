import Foundation

enum WeatherCondition: String {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "snowflake"
        }
    }
}

struct WeatherProfile {
    let temperature: Int // Celsius
    let condition: WeatherCondition
    
    var isHot: Bool { temperature >= 25 }
    var isCold: Bool { temperature <= 15 }
}

class WeatherService {
    static let shared = WeatherService()
    
    // Smart mock that cycles based on the day of the year
    func currentProfile() -> WeatherProfile {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Pseudo-random but consistent for the day
        let isSummer = (dayOfYear % 2 == 0) // toggles every day for testing
        let condition: WeatherCondition = isSummer ? .sunny : .cloudy
        let temp = isSummer ? Int.random(in: 25...35) : Int.random(in: 5...15)
        
        return WeatherProfile(temperature: temp, condition: condition)
    }
}
