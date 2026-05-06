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
        // Delete all body photos
        for filename in profile.bodyPhotoFilenames {
            if let fn = filename {
                deletePhotoFile(fn)
            }
        }
        if let fn = profile.profilePhotoFilename {
            deletePhotoFile(fn)
        }
        
        profile = UserProfile()
        isOnboardingComplete = false
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
    }
    
    // MARK: - Body Photo Management
    
    func saveBodyPhoto(_ imageData: Data, position: BodyPhotoPosition) -> String {
        // Delete old photo if exists
        if let oldFilename = profile.bodyPhotoFilenames[position.rawValue] {
            deletePhotoFile(oldFilename)
        }
        
        let filename = "body_\(position.label.lowercased())_\(UUID().uuidString).jpg"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        try? imageData.write(to: url)
        
        var filenames = profile.bodyPhotoFilenames
        filenames[position.rawValue] = filename
        profile.bodyPhotoFilenames = filenames
        
        return filename
    }
    
    func deleteBodyPhoto(at position: BodyPhotoPosition) {
        if let filename = profile.bodyPhotoFilenames[position.rawValue] {
            deletePhotoFile(filename)
        }
        var filenames = profile.bodyPhotoFilenames
        filenames[position.rawValue] = nil
        profile.bodyPhotoFilenames = filenames
    }
    
    func loadBodyPhoto(at position: BodyPhotoPosition) -> UIImage? {
        guard let filename = profile.bodyPhotoFilenames[position.rawValue] else { return nil }
        return loadPhoto(filename: filename)
    }
    
    // MARK: - Profile Photo
    
    func saveProfilePhoto(_ imageData: Data) -> String {
        if let old = profile.profilePhotoFilename {
            deletePhotoFile(old)
        }
        let filename = "profile_\(UUID().uuidString).jpg"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        try? imageData.write(to: url)
        profile.profilePhotoFilename = filename
        return filename
    }
    
    func loadProfilePhoto() -> UIImage? {
        guard let filename = profile.profilePhotoFilename else { return nil }
        return loadPhoto(filename: filename)
    }
    
    // MARK: - Zodiac Override
    
    func setZodiacOverride(_ sign: ZodiacSign?) {
        profile.zodiacOverride = sign
    }
    
    // MARK: - Helpers
    
    func loadPhoto(filename: String) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    private func deletePhotoFile(_ filename: String) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
