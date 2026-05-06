import SwiftUI
import PhotosUI

struct BodyPhotoUploadView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @State private var showDeleteConfirm = false
    @State private var deletePosition: BodyPhotoPosition?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(Theme.accentBlue)
                Text("Body Photos")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Text("\(profileVM.profile.bodyPhotoCount)/4")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.accentBlue.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Text("Upload photos from 4 angles for your style avatar")
                .font(.caption)
                .foregroundColor(Theme.textMuted)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(BodyPhotoPosition.allCases, id: \.rawValue) { position in
                    BodyPhotoCellView(
                        profileVM: profileVM,
                        position: position,
                        onDelete: {
                            deletePosition = position
                            showDeleteConfirm = true
                        }
                    )
                }
            }
        }
        .padding(16)
        .glassCard()
        .alert("Delete Photo?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let pos = deletePosition {
                    profileVM.deleteBodyPhoto(at: pos)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the \(deletePosition?.label ?? "") photo.")
        }
    }
}

// MARK: - Individual Photo Cell (each has its own PhotosPicker)

struct BodyPhotoCellView: View {
    @ObservedObject var profileVM: ProfileViewModel
    let position: BodyPhotoPosition
    let onDelete: () -> Void
    
    @State private var pickerItem: PhotosPickerItem?
    
    var body: some View {
        let photo = profileVM.loadBodyPhoto(at: position)
        
        ZStack {
            if let photo = photo {
                // Show uploaded photo with delete button
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(alignment: .topTrailing) {
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                        .padding(6)
                    }
                    .overlay(alignment: .bottom) {
                        Text(position.label)
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(.bottom, 6)
                    }
            } else {
                // Empty slot — PhotosPicker button
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: position.icon)
                            .font(.system(size: 28))
                            .foregroundColor(Theme.accentBlue.opacity(0.5))
                        
                        Text(position.label)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Theme.textSecondary)
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                            .foregroundColor(Theme.accentBlue)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.accentBlue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                    .foregroundColor(Theme.accentBlue.opacity(0.2))
                            )
                    )
                }
            }
        }
        .onChange(of: pickerItem) { newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        _ = profileVM.saveBodyPhoto(data, position: position)
                        pickerItem = nil
                    }
                }
            }
        }
    }
}
