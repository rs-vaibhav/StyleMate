import SwiftUI
import PhotosUI

struct AddItemView: View {
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category: ClothingCategory = .top
    @State private var selectedColor: AppColor = .blue
    @State private var occasion: Occasion = .casual
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.05, blue: 0.18)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Photo Section
                        photoSection
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Item Name")
                            TextField("e.g. Navy Blue Polo", text: $name)
                                .font(.body)
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .foregroundColor(.white)
                                .accentColor(Color(red: 0.6, green: 0.3, blue: 0.9))
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Category")
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
                                        .foregroundColor(category == cat ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            category == cat
                                                ? AnyShapeStyle(LinearGradient.cosmicAccent)
                                                : AnyShapeStyle(Color.white.opacity(0.06))
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Color")
                            colorPickerGrid
                        }
                        
                        // Occasion
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Occasion")
                            HStack(spacing: 10) {
                                ForEach(Occasion.allCases, id: \.self) { occ in
                                    Button {
                                        occasion = occ
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: occ.icon)
                                                .font(.body)
                                            Text(occ.rawValue)
                                                .font(.caption2.weight(.medium))
                                        }
                                        .foregroundColor(occasion == occ ? .white : .white.opacity(0.4))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            occasion == occ
                                                ? AnyShapeStyle(LinearGradient.cosmicAccent)
                                                : AnyShapeStyle(Color.white.opacity(0.06))
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
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
                                LinearGradient.cosmicAccent
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(red: 0.5, green: 0.2, blue: 0.9).opacity(0.4), radius: 10, y: 4)
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                        
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
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = photoImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedColor.color.opacity(0.3))
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.4))
                            Text("Add Photo (Optional)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }
                    )
            }
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text(photoImage == nil ? "Choose Photo" : "Change Photo")
                }
                .font(.callout.weight(.medium))
                .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.9))
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                        photoImage = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    // MARK: - Color Picker Grid
    
    private var colorPickerGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(AppColor.allCases) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .overlay(
                            selectedColor == color
                                ? Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(color.needsDarkText ? .black : .white)
                                : nil
                        )
                        .shadow(color: selectedColor == color ? color.color.opacity(0.5) : .clear, radius: 6)
                }
            }
        }
    }
    
    // MARK: - Save
    
    private func saveItem() {
        var filename: String? = nil
        if let data = photoData {
            filename = wardrobeVM.savePhoto(data)
        }
        
        let item = WardrobeItem(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            color: selectedColor,
            occasion: occasion,
            photoFilename: filename
        )
        
        wardrobeVM.addItem(item)
        dismiss()
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(.white.opacity(0.7))
    }
}
