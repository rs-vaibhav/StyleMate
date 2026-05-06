import SwiftUI

struct ContentView: View {
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var wardrobeVM = WardrobeViewModel()
    @StateObject private var outfitVM = OutfitViewModel()
    
    @State private var selectedTab = 0
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            VibrantBackground()
            
            if !profileVM.isOnboardingComplete {
                OnboardingView(profileVM: profileVM)
                    .transition(.opacity)
            } else {
                mainTabView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: profileVM.isOnboardingComplete)
    }
    
    // MARK: - Tab View
    
    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView(profileVM: profileVM, wardrobeVM: wardrobeVM, outfitVM: outfitVM)
                case 1:
                    WardrobeView(wardrobeVM: wardrobeVM)
                case 2:
                    AvatarTabView(profileVM: profileVM, wardrobeVM: wardrobeVM, outfitVM: outfitVM)
                case 3:
                    HistoryView(profileVM: profileVM, outfitVM: outfitVM, wardrobeVM: wardrobeVM)
                default:
                    HomeView(profileVM: profileVM, wardrobeVM: wardrobeVM, outfitVM: outfitVM)
                }
            }
            
            // Custom Tab Bar
            customTabBar
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "sparkles", activeIcon: "sparkles", label: "Today", index: 0)
            tabItem(icon: "tshirt", activeIcon: "tshirt.fill", label: "Wardrobe", index: 1)
            tabItem(icon: "cube", activeIcon: "cube.fill", label: "3D Me", index: 2)
            tabItem(icon: "clock.arrow.circlepath", activeIcon: "clock.arrow.circlepath", label: "History", index: 3)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Theme.shadowMedium, radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    private func tabItem(icon: String, activeIcon: String, label: String, index: Int) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == index ? activeIcon : icon)
                    .font(.system(size: 22, weight: selectedTab == index ? .semibold : .regular))
                    .foregroundColor(selectedTab == index ? Theme.accentRed : Theme.textMuted)
                
                Text(label)
                    .font(.system(size: 11, weight: selectedTab == index ? .bold : .medium, design: .rounded))
                    .foregroundColor(selectedTab == index ? Theme.accentRed : Theme.textMuted)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if selectedTab == index {
                        Capsule()
                            .fill(Theme.accentRed.opacity(0.10))
                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: animation)
                    }
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
