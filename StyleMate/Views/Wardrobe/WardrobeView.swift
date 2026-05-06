import SwiftUI

struct WardrobeView: View {
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @State private var selectedCategory: ClothingCategory? = nil
    @State private var showAddItem = false
    @State private var editingItem: WardrobeItem? = nil
    
    private var filteredItems: [WardrobeItem] {
        if let cat = selectedCategory {
            return wardrobeVM.items(for: cat)
        }
        return wardrobeVM.items
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("My Wardrobe")
                    .font(.title.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                
                Text("\(wardrobeVM.items.count) items")
                    .font(.callout)
                    .foregroundColor(Theme.textSecondary)
                
                // Category Stats
                HStack(spacing: 12) {
                    statBadge(icon: "tshirt.fill", count: wardrobeVM.topCount, label: "Tops", color: Theme.accentRed)
                    statBadge(icon: "rectangle.split.1x2.fill", count: wardrobeVM.bottomCount, label: "Bottoms", color: Theme.accentBlue)
                    statBadge(icon: "shoeprints.fill", count: wardrobeVM.footwearCount, label: "Shoes", color: Theme.accentGreen)
                    statBadge(icon: "sparkles", count: wardrobeVM.accessoryCount, label: "Acc.", color: Theme.accentYellow)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    filterChip(label: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(ClothingCategory.allCases, id: \.self) { cat in
                        filterChip(
                            label: cat.rawValue,
                            icon: cat.icon,
                            isSelected: selectedCategory == cat
                        ) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
            
            // Items Grid
            if filteredItems.isEmpty {
                Spacer()
                emptyState
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                            wardrobeItemCard(item)
                                .onTapGesture {
                                    editingItem = item
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.04), value: filteredItems.count)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // FAB
            Button {
                showAddItem = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient.vibrantAccent
                    )
                    .clipShape(Circle())
                    .shadow(color: Theme.accentRed.opacity(0.4), radius: 12, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
        .sheet(isPresented: $showAddItem) {
            AddItemView(wardrobeVM: wardrobeVM)
        }
        .sheet(item: $editingItem) { item in
            EditItemView(wardrobeVM: wardrobeVM, item: item)
        }
    }
    
    // MARK: - Components
    
    private func statBadge(icon: String, count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text("\(count)")
                .font(.callout.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 12)
    }
    
    private func filterChip(label: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(isSelected ? .white : Theme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient.vibrantAccent)
                    : AnyShapeStyle(Color.white)
            )
            .clipShape(Capsule())
            .shadow(color: isSelected ? Theme.accentRed.opacity(0.3) : Theme.shadowLight, radius: 4, y: 2)
        }
    }
    
    private func wardrobeItemCard(_ item: WardrobeItem) -> some View {
        VStack(spacing: 10) {
            // Photo or color swatch
            ZStack(alignment: .topTrailing) {
                if let filename = item.photoFilename,
                   let image = wardrobeVM.loadPhoto(filename: filename) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color.color)
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: item.category.icon)
                                .font(.system(size: 30))
                                .foregroundColor(item.color.needsDarkText ? .black.opacity(0.2) : .white.opacity(0.3))
                        )
                }
                
                // Edit badge
                Image(systemName: "pencil.circle.fill")
                    .font(.body)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3)
                    .padding(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.callout.weight(.medium))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.color.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.color.displayName)
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                    
                    Spacer()
                    
                    Text(item.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(10)
        .glassCard(cornerRadius: 16)
        .contextMenu {
            Button {
                editingItem = item
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                wardrobeVM.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "hanger")
                .font(.system(size: 50))
                .foregroundColor(Theme.textMuted)
            
            Text(selectedCategory != nil ? "No \(selectedCategory!.rawValue) items yet" : "Your wardrobe is empty")
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
            
            Text("Tap + to add your first item")
                .font(.callout)
                .foregroundColor(Theme.textMuted)
        }
    }
}
