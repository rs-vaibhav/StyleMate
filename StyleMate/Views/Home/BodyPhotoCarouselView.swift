import SwiftUI

struct BodyPhotoCarouselView: View {
    @ObservedObject var profileVM: ProfileViewModel
    var outfitColors: [AppColor]
    
    @State private var currentPage = 0
    
    private var availablePhotos: [(BodyPhotoPosition, UIImage)] {
        BodyPhotoPosition.allCases.compactMap { position in
            if let image = profileVM.loadBodyPhoto(at: position) {
                return (position, image)
            }
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Style Avatar")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                if !outfitColors.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(outfitColors.prefix(4)), id: \.self) { color in
                            Circle()
                                .fill(color.color)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                        }
                    }
                }
            }
            
            if availablePhotos.isEmpty {
                // Placeholder — prompt to add photos
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.rectangle.stack.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Theme.accentBlue.opacity(0.3))
                    
                    Text("Add body photos in Settings")
                        .font(.callout.weight(.medium))
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("Upload from 4 angles to see your style avatar")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .glassCard()
            } else {
                // Photo Carousel
                TabView(selection: $currentPage) {
                    ForEach(Array(availablePhotos.enumerated()), id: \.offset) { index, item in
                        ZStack(alignment: .bottom) {
                            Image(uiImage: item.1)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Outfit color overlay bar
                            if !outfitColors.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(Array(outfitColors.prefix(4)), id: \.self) { color in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 10, height: 10)
                                            Text(color.displayName)
                                                .font(.caption2.weight(.medium))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                            
                            // Position label
                            VStack {
                                HStack {
                                    Text(item.0.label)
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                    
                                    Spacer()
                                }
                                .padding(12)
                                
                                Spacer()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 330)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Theme.shadowMedium, radius: 12, x: 0, y: 6)
            }
        }
        .padding(.horizontal, 16)
    }
}
