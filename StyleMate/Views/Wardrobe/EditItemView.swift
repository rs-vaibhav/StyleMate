import SwiftUI
import PhotosUI

struct EditItemView: View {
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @Environment(\.dismiss) private var dismiss
    
    let item: WardrobeItem
    
    @State private var name: String
    @State private var category: ClothingCategory
    @State private var selectedColor: AppColor
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoImage: UIImage?
    @State private var extractedImage: UIImage?
    @State private var showColorPicker = false
    
    init(wardrobeVM: WardrobeViewModel, item: WardrobeItem) {
        self.wardrobeVM = wardrobeVM
        self.item = item
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        _selectedColor = State(initialValue: item.color)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Photo
                        photoSection
                        
                        // Name (editable)
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Item Name")
                            TextField("e.g. Navy Blue Polo", text: $name)
                                .font(.body)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .foregroundColor(Theme.textPrimary)
                                .shadow(color: Theme.shadowLight, radius: 4, x: 0, y: 2)
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
                        
                        // Color — detected + editable
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                sectionLabel("Color")
                                Spacer()
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        showColorPicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: showColorPicker ? "chevron.up" : "pencil")
                                            .font(.caption2)
                                        Text(showColorPicker ? "Close" : "Change")
                                            .font(.caption.weight(.medium))
                                    }
                                    .foregroundColor(Theme.accentBlue)
                                }
                            }
                            
                            // Current color display
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(selectedColor.color)
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(color: selectedColor.color.opacity(0.3), radius: 4)
                                
                                Text(selectedColor.displayName)
                                    .font(.callout.weight(.semibold))
                                    .foregroundColor(Theme.textPrimary)
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Theme.shadowLight, radius: 4, y: 2)
                            
                            // Expandable color picker grid
                            if showColorPicker {
                                colorPickerGrid
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        
                        // Save Button
                        Button {
                            saveChanges()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Changes")
                            }
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient.vibrantAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Theme.accentRed.opacity(0.4), radius: 10, y: 4)
                        }
                        
                        // Delete Button
                        Button {
                            wardrobeVM.deleteItem(item)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Item")
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
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = photoImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Theme.shadowMedium, radius: 12, x: 0, y: 6)
            } else if let fn = item.photoFilename, let image = wardrobeVM.loadPhoto(filename: fn) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Theme.shadowMedium, radius: 12, x: 0, y: 6)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedColor.color.opacity(0.15))
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundColor(Theme.textMuted)
                            Text("No Photo")
                                .font(.caption)
                                .foregroundColor(Theme.textMuted)
                        }
                    )
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                    Text("Change Photo")
                }
                .font(.callout.weight(.medium))
                .foregroundColor(Theme.accentBlue)
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            photoData = data
                            photoImage = UIImage(data: data)
                            // Extract clothing using Vision ML
                            if let img = photoImage {
                                ClothingExtractor.extractClothing(from: img) { extracted in
                                    self.extractedImage = extracted
                                    let analyzeImg = extracted ?? img
                                    withAnimation {
                                        selectedColor = ImageColorExtractor.dominantAppColor(from: analyzeImg)
                                        name = ImageColorExtractor.autoName(color: selectedColor, category: category)
                                    }
                                }
                            }
                        }
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
                    withAnimation(.spring(response: 0.3)) {
                        selectedColor = color
                    }
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Theme.accentRed, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .overlay(
                            selectedColor == color
                                ? Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(color.needsDarkText ? .black : .white)
                                : nil
                        )
                        .shadow(color: selectedColor == color ? color.color.opacity(0.4) : .clear, radius: 6)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Theme.shadowLight, radius: 4, y: 2)
    }
    
    // MARK: - Save
    
    private func saveChanges() {
        var updated = item
        updated.name = name.trimmingCharacters(in: .whitespaces).isEmpty ? ImageColorExtractor.autoName(color: selectedColor, category: category) : name
        updated.category = category
        updated.color = selectedColor
        
        if photoImage != nil {
            // Delete old photo
            if let oldFn = item.photoFilename {
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                try? FileManager.default.removeItem(at: docs.appendingPathComponent(oldFn))
            }
            // Save ML-extracted clothing image (no background)
            let saveImg = extractedImage ?? photoImage
            if let img = saveImg, let data = img.pngData() ?? img.jpegData(compressionQuality: 0.9) {
                updated.photoFilename = wardrobeVM.savePhoto(data)
            }
        }
        
        wardrobeVM.updateItem(updated)
        dismiss()
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundColor(Theme.textSecondary)
    }
}
