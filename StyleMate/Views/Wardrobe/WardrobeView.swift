import SwiftUI

struct WardrobeView: View {
    @ObservedObject var wardrobeVM: WardrobeViewModel
    @State private var selectedCategory: ClothingCategory? = nil
    @State private var showAddItem = false
    
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
                    .foregroundColor(.white)
                
                Text("\(wardrobeVM.items.count) items")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.5))
                
                // Category Stats
                HStack(spacing: 12) {
                    statBadge(icon: "tshirt.fill", count: wardrobeVM.topCount, label: "Tops")
                    statBadge(icon: "rectangle.split.1x2.fill", count: wardrobeVM.bottomCount, label: "Bottoms")
                    statBadge(icon: "shoeprints.fill", count: wardrobeVM.footwearCount, label: "Shoes")
                    statBadge(icon: "sparkles", count: wardrobeVM.accessoryCount, label: "Acc.")
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
                        ForEach(filteredItems) { item in
                            wardrobeItemCard(item)
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
                        LinearGradient.cosmicAccent
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0.5, green: 0.2, blue: 0.9).opacity(0.5), radius: 12, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
        .sheet(isPresented: $showAddItem) {
            AddItemView(wardrobeVM: wardrobeVM)
        }
    }
    
    // MARK: - Components
    
    private func statBadge(icon: String, count: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            Text("\(count)")
                .font(.callout.weight(.bold))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
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
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient.cosmicAccent)
                    : AnyShapeStyle(Color.white.opacity(0.08))
            )
            .clipShape(Capsule())
        }
    }
    
    private func wardrobeItemCard(_ item: WardrobeItem) -> some View {
        VStack(spacing: 10) {
            // Photo or color swatch
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
                            .foregroundColor(item.color.needsDarkText ? .black.opacity(0.3) : .white.opacity(0.3))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.callout.weight(.medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.color.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.color.displayName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text(item.occasion.rawValue)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(10)
        .glassCard(cornerRadius: 16)
        .contextMenu {
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
                .foregroundColor(.white.opacity(0.2))
            
            Text(selectedCategory != nil ? "No \(selectedCategory!.rawValue) items yet" : "Your wardrobe is empty")
                .font(.headline)
                .foregroundColor(.white.opacity(0.5))
            
            Text("Tap + to add your first item")
                .font(.callout)
                .foregroundColor(.white.opacity(0.3))
        }
    }
}
