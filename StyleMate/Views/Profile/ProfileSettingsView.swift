import SwiftUI
import PhotosUI

struct ProfileSettingsView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var useZodiacOverride: Bool
    @State private var selectedZodiac: ZodiacSign
    @State private var showResetConfirm = false
    
    init(profileVM: ProfileViewModel) {
        self.profileVM = profileVM
        _useZodiacOverride = State(initialValue: profileVM.profile.zodiacOverride != nil)
        _selectedZodiac = State(initialValue: profileVM.profile.zodiacOverride ?? profileVM.profile.autoZodiacSign)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile Header
                        profileHeader
                        
                        // Personal Details
                        personalDetailsSection
                        
                        // Astrology
                        astrologySection
                        
                        // Style & Body
                        styleBodySection
                        
                        // Body Photos
                        BodyPhotoUploadView(profileVM: profileVM)
                        .padding(.horizontal, 16)
                        
                        // Danger Zone
                        dangerZone
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(Theme.accentRed)
                }
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient.vibrantAccent
                    )
                    .frame(width: 80, height: 80)
                
                if let photo = profileVM.loadProfilePhoto() {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 76, height: 76)
                        .clipShape(Circle())
                } else {
                    Image(systemName: profileVM.profile.gender.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            
            Text(profileVM.profile.name.isEmpty ? "Your Name" : profileVM.profile.name)
                .font(.title2.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            HStack(spacing: 6) {
                Text(profileVM.profile.zodiacSign.symbol)
                Text(profileVM.profile.zodiacSign.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.accentPurple)
                Text("•")
                    .foregroundColor(Theme.textMuted)
                Text(profileVM.profile.zodiacSign.element)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Personal Details
    
    private var personalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "person.fill", title: "Personal Details", color: Theme.accentBlue)
            
            // Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                
                TextField("Enter your name", text: $profileVM.profile.name)
                    .font(.body)
                    .padding(12)
                    .background(Theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(Theme.textPrimary)
            }
            
            // Date of Birth
            VStack(alignment: .leading, spacing: 6) {
                Text("Date of Birth")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                
                DatePicker("", selection: $profileVM.profile.dateOfBirth, displayedComponents: .date)
                    .labelsHidden()
                    .padding(8)
                    .background(Theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: profileVM.profile.dateOfBirth) { _ in
                        if !useZodiacOverride {
                            selectedZodiac = profileVM.profile.autoZodiacSign
                        }
                    }
            }
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Astrology
    
    private var astrologySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "sparkles", title: "Astrology", color: Theme.accentPurple)
            
            // Auto-calculated
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto from DOB")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.textSecondary)
                    Text("\(profileVM.profile.autoZodiacSign.symbol) \(profileVM.profile.autoZodiacSign.rawValue)")
                        .font(.body.weight(.medium))
                        .foregroundColor(Theme.textPrimary)
                }
                
                Spacer()
                
                Text(profileVM.profile.autoZodiacSign.element)
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
            }
            .padding(12)
            .background(Theme.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Override toggle
            Toggle(isOn: $useZodiacOverride) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Manual Override")
                        .font(.callout.weight(.medium))
                        .foregroundColor(Theme.textPrimary)
                    Text("Choose a different zodiac sign")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                }
            }
            .tint(Theme.accentPurple)
            .onChange(of: useZodiacOverride) { enabled in
                if enabled {
                    profileVM.setZodiacOverride(selectedZodiac)
                } else {
                    profileVM.setZodiacOverride(nil)
                }
            }
            
            // Zodiac picker
            if useZodiacOverride {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ZodiacSign.allCases, id: \.self) { sign in
                            Button {
                                selectedZodiac = sign
                                profileVM.setZodiacOverride(sign)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(sign.symbol)
                                        .font(.title2)
                                    Text(sign.rawValue)
                                        .font(.caption2.weight(.medium))
                                }
                                .foregroundColor(selectedZodiac == sign ? .white : Theme.textSecondary)
                                .frame(width: 64, height: 64)
                                .background(
                                    selectedZodiac == sign
                                        ? AnyShapeStyle(LinearGradient(colors: [Theme.accentPurple, Theme.accentPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        : AnyShapeStyle(Theme.background)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: useZodiacOverride)
            }
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Style & Body
    
    private var styleBodySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "figure.arms.open", title: "Style & Body", color: Theme.accentGreen)
            
            // Gender
            VStack(alignment: .leading, spacing: 6) {
                Text("Style Vibe")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                
                HStack(spacing: 8) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Button {
                            profileVM.profile.gender = gender
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: gender.icon)
                                    .font(.title3)
                                Text(gender.rawValue)
                                    .font(.caption2.weight(.medium))
                            }
                            .foregroundColor(profileVM.profile.gender == gender ? .white : Theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                profileVM.profile.gender == gender
                                    ? AnyShapeStyle(LinearGradient.freshGreen)
                                    : AnyShapeStyle(Theme.background)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            
            // Skin Tone
            VStack(alignment: .leading, spacing: 6) {
                Text("Skin Tone")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                
                HStack(spacing: 8) {
                    ForEach(SkinTone.allCases, id: \.self) { tone in
                        Button {
                            profileVM.profile.skinTone = tone
                        } label: {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(skinToneColor(tone))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                profileVM.profile.skinTone == tone ? Theme.accentGreen : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                                Text(tone.rawValue)
                                    .font(.caption2.weight(.medium))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                profileVM.profile.skinTone == tone ? Theme.accentGreen.opacity(0.08) : Theme.background
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            
            // Body Type
            VStack(alignment: .leading, spacing: 6) {
                Text("Body Type")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                
                HStack(spacing: 8) {
                    ForEach(BodyType.allCases, id: \.self) { type in
                        Button {
                            profileVM.profile.bodyType = type
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: bodyTypeIcon(type))
                                    .font(.title3)
                                Text(type.rawValue)
                                    .font(.caption2.weight(.medium))
                            }
                            .foregroundColor(profileVM.profile.bodyType == type ? .white : Theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                profileVM.profile.bodyType == type
                                    ? AnyShapeStyle(LinearGradient.freshGreen)
                                    : AnyShapeStyle(Theme.background)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Danger Zone
    
    private var dangerZone: some View {
        VStack(spacing: 12) {
            Button {
                showResetConfirm = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset Profile & Start Over")
                }
                .font(.callout.weight(.medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.red.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .alert("Reset Everything?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) {
                profileVM.resetProfile()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all your profile data, body photos, and settings. This action cannot be undone.")
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
        }
    }
    
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
