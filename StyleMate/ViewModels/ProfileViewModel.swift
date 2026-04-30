import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile {
        didSet { save() }
    }
    @Published var isOnboardingComplete: Bool {
        didSet { UserDefaults.standard.set(isOnboardingComplete, forKey: "onboardingComplete") }
    }
    
    private let profileKey = "userProfile"
    
    init() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = UserProfile()
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        save()
    }
    
    func resetProfile() {
        profile = UserProfile()
        isOnboardingComplete = false
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
    }
}
