import SwiftUI

enum AppIconStyle: String, CaseIterable {
    case defaultIcon = "Default"
    case darkMode = "Dark"
    case vibrant = "Vibrant"
    
    var iconName: String? {
        switch self {
        case .defaultIcon: return nil // nil means the primary icon
        case .darkMode: return "AppIconDark"
        case .vibrant: return "AppIconVibrant"
        }
    }
}

class AppIconManager: ObservableObject {
    static let shared = AppIconManager()
    
    @Published var currentIcon: AppIconStyle = .defaultIcon
    
    init() {
        // Find current icon on init
        if let iconName = UIApplication.shared.alternateIconName {
            if iconName == AppIconStyle.darkMode.iconName {
                currentIcon = .darkMode
            } else if iconName == AppIconStyle.vibrant.iconName {
                currentIcon = .vibrant
            }
        }
    }
    
    func changeIcon(to style: AppIconStyle) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(style.iconName) { error in
            if let error = error {
                print("Error setting alternate icon: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.currentIcon = style
                }
            }
        }
    }
}
