import SwiftUI

struct ContentView: View {
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var wardrobeVM = WardrobeViewModel()
    @StateObject private var outfitVM = OutfitViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            if !profileVM.isOnboardingComplete {
                OnboardingView(profileVM: profileVM)
                    .transition(.opacity)
            } else {
                mainTabView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: profileVM.isOnboardingComplete)
        .preferredColorScheme(.dark)
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
                    WeeklyPlannerView(profileVM: profileVM, wardrobeVM: wardrobeVM, outfitVM: outfitVM)
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
        HStack {
            tabItem(icon: "sparkles", label: "Today", index: 0)
            tabItem(icon: "hanger", label: "Wardrobe", index: 1)
            tabItem(icon: "calendar", label: "Planner", index: 2)
            tabItem(icon: "clock.arrow.circlepath", label: "History", index: 3)
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.05, green: 0.02, blue: 0.15).opacity(0.5))
                )
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.5)
                }
                .ignoresSafeArea()
        )
    }
    
    private func tabItem(icon: String, label: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == index ? icon + (icon == "hanger" || icon == "calendar" ? "" : "") : icon)
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(
                        selectedTab == index
                            ? Color(red: 0.7, green: 0.4, blue: 1.0)
                            : .white.opacity(0.4)
                    )
                    .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(
                        selectedTab == index
                            ? Color(red: 0.7, green: 0.4, blue: 1.0)
                            : .white.opacity(0.4)
                    )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
