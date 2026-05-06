import SwiftUI
import PhotosUI

struct AddItemView: View {
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var category: ClothingCategory = .top
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: UIImage?
    @State private var extractedImage: UIImage?  // ML-extracted clothing (no background)
    @State private var detectedColor: AppColor = .blue
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Photo Section — THE main input
                        photoSection
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("What is it?")
                            HStack(spacing: 10) {
                                ForEach(ClothingCategory.allCases, id: \.self) { cat in
                                    Button {
                                        category = cat
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                                .font(.title3)
                                            Text(cat.rawValue)
                                                .font(.caption2.weight(.medium))
                                        }
                                        .foregroundColor(category == cat ? .white : Theme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            category == cat
                                                ? AnyShapeStyle(LinearGradient.vibrantAccent)
                                                : AnyShapeStyle(Color.white)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: category == cat ? Theme.accentRed.opacity(0.3) : Theme.shadowLight, radius: 4, y: 2)
                                    }
                                }
                            }
                        }
                        
                        // Detected color preview (read-only info)
                        if photoImage != nil {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(detectedColor.color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(color: detectedColor.color.opacity(0.3), radius: 4)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Detected Color")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(Theme.textSecondary)
                                    Text(detectedColor.displayName)
                                        .font(.callout.weight(.bold))
                                        .foregroundColor(Theme.textPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Theme.accentGreen)
                            }
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Theme.shadowLight, radius: 4, y: 2)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        // Save Button
                        Button {
                            saveItem()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add to Wardrobe")
                            }
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient.vibrantAccent
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Theme.accentRed.opacity(0.4), radius: 10, y: 4)
                        }
                        .disabled(photoImage == nil)
                        .opacity(photoImage == nil ? 0.4 : 1)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(spacing: 14) {
            if let image = photoImage {
                // Show the uploaded photo large
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Theme.shadowMedium, radius: 12, x: 0, y: 6)
                    .overlay(alignment: .topTrailing) {
                        // Analyzing indicator
                        if isAnalyzing {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .tint(.white)
                                Text("Analyzing...")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(10)
                        }
                    }
                
                // Change photo
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                        Text("Change Photo")
                    }
                    .font(.callout.weight(.medium))
                    .foregroundColor(Theme.accentBlue)
                }
            } else {
                // Empty state — big prompt to upload
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images
                ) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentBlue.opacity(0.08))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Theme.accentBlue)
                        }
                        
                        Text("Upload Clothing Photo")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("Take a photo or pick from gallery\nThe app will detect the color automatically")
                            .font(.caption)
                            .foregroundColor(Theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Theme.accentBlue.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2.5, dash: [10]))
                                    .foregroundColor(Theme.accentBlue.opacity(0.25))
                            )
                    )
                }
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        photoData = data
                        photoImage = UIImage(data: data)
                        analyzePhoto()
                    }
                }
            }
        }
    }
    
    // MARK: - Analyze Photo (Vision ML extraction)
    
    private func analyzePhoto() {
        guard let image = photoImage else { return }
        isAnalyzing = true
        
        // Step 1: Extract clothing from background using Vision ML
        ClothingExtractor.extractClothing(from: image) { extracted in
            withAnimation(.spring(response: 0.4)) {
                // Use extracted image if available, otherwise original
                self.extractedImage = extracted
                let analyzeImg = extracted ?? image
                self.detectedColor = ImageColorExtractor.dominantAppColor(from: analyzeImg)
                self.isAnalyzing = false
            }
        }
    }
    
    // MARK: - Save
    
    private func saveItem() {
        // Save the ML-extracted clothing image (no background) for 3D texturing
        let saveImage = extractedImage ?? photoImage
        guard let img = saveImage, let data = img.pngData() ?? img.jpegData(compressionQuality: 0.9) else { return }
        
        let filename = wardrobeVM.savePhoto(data)
        let autoName = ImageColorExtractor.autoName(color: detectedColor, category: category)
        
        let item = WardrobeItem(
            name: autoName,
            category: category,
            color: detectedColor,
            occasion: .casual,
            photoFilename: filename
        )
        
        wardrobeVM.addItem(item)
        dismiss()
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(Theme.textSecondary)
    }
}
