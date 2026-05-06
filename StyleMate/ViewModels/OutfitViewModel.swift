import Foundation
import SwiftUI

class OutfitViewModel: ObservableObject {
    @Published var currentSuggestion: OutfitSuggestion?
    @Published var history: [OutfitSuggestion] = []
    @Published var weeklyPlan: [Date: OutfitSuggestion] = [:]
    
    private var excludedIDs: [UUID] = []
    
    private var historyFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("outfit_history.json")
    }
    
    init() {
        loadHistory()
    }
    
    func generateSuggestion(for date: Date, profile: UserProfile, wardrobe: [WardrobeItem], occasion: Occasion = .casual, weather: WeatherProfile? = nil) {
        let suggestion = AstrologyEngine.suggestOutfit(
            for: date,
            profile: profile,
            wardrobe: wardrobe,
            excluding: excludedIDs,
            occasion: occasion,
            weather: weather
        )
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentSuggestion = suggestion
        }
    }
    
    func shuffleSuggestion(for date: Date, profile: UserProfile, wardrobe: [WardrobeItem], occasion: Occasion = .casual, weather: WeatherProfile? = nil) {
        // Exclude current items to get different ones
        if let current = currentSuggestion {
            excludedIDs.append(contentsOf: current.allItems.map(\.id))
        }
        
        // If we've excluded everything, reset
        if excludedIDs.count >= wardrobe.count {
            excludedIDs = []
        }
        
        generateSuggestion(for: date, profile: profile, wardrobe: wardrobe, occasion: occasion, weather: weather)
    }
    
    func confirmOutfit() {
        guard var suggestion = currentSuggestion else { return }
        suggestion.confirmed = true
        
        // Remove any existing entry for this date
        history.removeAll { $0.date.isSameDay(as: suggestion.date) }
        history.append(suggestion)
        saveHistory()
        
        currentSuggestion = suggestion
        excludedIDs = []
    }
    
    func outfit(for date: Date) -> OutfitSuggestion? {
        history.first { $0.date.isSameDay(as: date) }
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(history) else { return }
        try? data.write(to: historyFileURL)
    }
    
    private func loadHistory() {
        guard let data = try? Data(contentsOf: historyFileURL),
              let saved = try? JSONDecoder().decode([OutfitSuggestion].self, from: data) else { return }
        history = saved
    }
}
