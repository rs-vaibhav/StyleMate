import SwiftUI

struct OnboardingView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @State private var step = 0
    @State private var animateIn = false
    
    let totalSteps = 5
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            VStack(spacing: 0) {
                // Progress bar
                HStack(spacing: 4) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color(red: 0.6, green: 0.3, blue: 0.9) : Color.white.opacity(0.2))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: step)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                // Step content
                Group {
                    switch step {
                    case 0: nameStep
                    case 1: dobStep
                    case 2: genderStep
                    case 3: skinToneStep
                    case 4: bodyTypeStep
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)
                
                Spacer()
                
                // Navigation
                HStack(spacing: 16) {
                    if step > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) { step -= 1 }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.body.weight(.medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if step < totalSteps - 1 {
                            withAnimation(.easeInOut(duration: 0.4)) { step += 1 }
                        } else {
                            profileVM.completeOnboarding()
                        }
                    } label: {
                        HStack {
                            Text(step == totalSteps - 1 ? "Get Started" : "Next")
                            Image(systemName: step == totalSteps - 1 ? "sparkles" : "chevron.right")
                        }
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient.cosmicAccent
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.5, green: 0.2, blue: 0.9).opacity(0.5), radius: 12, y: 4)
                    }
                    .disabled(step == 0 && profileVM.profile.name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(step == 0 && profileVM.profile.name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Step Views
    
    private var nameStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.goldenHour)
            
            Text("Welcome to StyleMate")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
            
            Text("Your cosmic style companion")
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.callout.weight(.medium))
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Enter your name", text: $profileVM.profile.name)
                    .font(.title3)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .foregroundColor(.white)
                    .accentColor(Color(red: 0.6, green: 0.3, blue: 0.9))
            }
            .padding(.horizontal, 30)
        }
        .padding(.horizontal, 20)
    }
    
    private var dobStep: some View {
        VStack(spacing: 24) {
            Text(profileVM.profile.zodiacSign.symbol)
                .font(.system(size: 70))
            
            Text("When were you born?")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
            
            Text("We'll determine your zodiac sign")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
            
            DatePicker("", selection: $profileVM.profile.dateOfBirth, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(maxHeight: 180)
            
            VStack(spacing: 8) {
                Text("Your sign: \(profileVM.profile.zodiacSign.rawValue) \(profileVM.profile.zodiacSign.symbol)")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.9))
                
                Text(profileVM.profile.zodiacSign.element)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .glassCard()
        }
        .padding(.horizontal, 20)
    }
    
    private var genderStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.stand")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.cosmicAccent)
            
            Text("What's your style vibe?")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
            
            Text("Helps us personalize suggestions")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 16) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button {
                        profileVM.profile.gender = gender
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: gender.icon)
                                .font(.system(size: 36))
                            Text(gender.rawValue)
                                .font(.callout.weight(.medium))
                        }
                        .foregroundColor(profileVM.profile.gender == gender ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            profileVM.profile.gender == gender
                                ? AnyShapeStyle(LinearGradient.cosmicAccent)
                                : AnyShapeStyle(Color.white.opacity(0.08))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    profileVM.profile.gender == gender
                                        ? Color(red: 0.6, green: 0.3, blue: 0.9)
                                        : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
    }
    
    private var skinToneStep: some View {
        VStack(spacing: 24) {
            Text("🎨")
                .font(.system(size: 60))
            
            Text("Your Skin Tone")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
            
            Text("For better color-matching recommendations")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 14) {
                ForEach(SkinTone.allCases, id: \.self) { tone in
                    Button {
                        profileVM.profile.skinTone = tone
                    } label: {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(skinToneColor(tone))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: profileVM.profile.skinTone == tone ? 3 : 0)
                                )
                            
                            Text(tone.rawValue)
                                .font(.caption.weight(.medium))
                                .foregroundColor(profileVM.profile.skinTone == tone ? .white : .white.opacity(0.5))
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            profileVM.profile.skinTone == tone
                                ? Color.white.opacity(0.15)
                                : Color.white.opacity(0.05)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
    }
    
    private var bodyTypeStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.arms.open")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.goldenHour)
            
            Text("Body Type")
                .font(.title.weight(.bold))
                .foregroundColor(.white)
            
            Text("For the perfect silhouette preview")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(BodyType.allCases, id: \.self) { type in
                    Button {
                        profileVM.profile.bodyType = type
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: bodyTypeIcon(type))
                                .font(.system(size: 32))
                            Text(type.rawValue)
                                .font(.callout.weight(.medium))
                        }
                        .foregroundColor(profileVM.profile.bodyType == type ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            profileVM.profile.bodyType == type
                                ? AnyShapeStyle(LinearGradient.cosmicAccent)
                                : AnyShapeStyle(Color.white.opacity(0.08))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helpers
    
    private func skinToneColor(_ tone: SkinTone) -> Color {
        switch tone {
        case .light: return Color(red: 1.0, green: 0.87, blue: 0.77)
        case .medium: return Color(red: 0.87, green: 0.72, blue: 0.53)
        case .tan: return Color(red: 0.73, green: 0.55, blue: 0.36)
        case .dark: return Color(red: 0.45, green: 0.30, blue: 0.18)
        }
    }
    
    private func bodyTypeIcon(_ type: BodyType) -> String {
        switch type {
        case .slim: return "figure.stand"
        case .athletic: return "figure.strengthtraining.traditional"
        case .average: return "figure.arms.open"
        case .heavy: return "figure.walk"
        }
    }
}
