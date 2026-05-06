import SwiftUI

struct HistoryView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var outfitVM: OutfitViewModel
    @ObservedObject var wardrobeVM: WardrobeViewModel
    
    @State private var selectedDate: Date? = nil
    
    private var monthDates: [Date] {
        Date.datesInCurrentMonth()
    }
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var streakCount: Int {
        var streak = 0
        let calendar = Calendar.current
        var date = Date()
        while outfitVM.outfit(for: date) != nil {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Style History")
                        .font(.title.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if streakCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Theme.accentOrange)
                            Text("\(streakCount) day streak!")
                                .font(.callout.weight(.semibold))
                                .foregroundColor(Theme.accentOrange)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.accentOrange.opacity(0.10))
                        .clipShape(Capsule())
                    }
                }
                .padding(.top, 16)
                
                // Month Label
                Text(currentMonth)
                    .font(.headline)
                    .foregroundColor(Theme.textSecondary)
                
                // Calendar Grid
                calendarGrid
                
                // Selected Date Detail
                if let date = selectedDate {
                    selectedDateDetail(date: date)
                }
                
                // Profile Card
                profileCard
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 4) {
            // Day headers
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(Theme.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Date cells
            let calendar = Calendar.current
            let firstDate = monthDates.first ?? Date()
            let firstWeekday = calendar.component(.weekday, from: firstDate) - 1
            let totalCells = firstWeekday + monthDates.count
            let rows = (totalCells + 6) / 7
            
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { col in
                        let index = row * 7 + col - firstWeekday
                        if index >= 0 && index < monthDates.count {
                            let date = monthDates[index]
                            let hasOutfit = outfitVM.outfit(for: date) != nil
                            let isSelected = selectedDate?.isSameDay(as: date) ?? false
                            let isToday = date.isToday
                            
                            Button {
                                selectedDate = date
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(date.dayNumber)")
                                        .font(.caption.weight(isToday ? .bold : .regular))
                                        .foregroundColor(isToday ? Theme.accentRed : Theme.textPrimary)
                                    
                                    if hasOutfit {
                                        Circle()
                                            .fill(Theme.accentGreen)
                                            .frame(width: 5, height: 5)
                                    } else {
                                        Circle()
                                            .fill(Color.clear)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    isSelected
                                        ? Theme.accentRed.opacity(0.10)
                                        : isToday
                                            ? Theme.accentRed.opacity(0.05)
                                            : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - Selected Date Detail
    
    private func selectedDateDetail(date: Date) -> some View {
        VStack(spacing: 12) {
            Text(date.dayOfWeekName + ", " + AstrologyEngine.formattedDate(date))
                .font(.callout.weight(.semibold))
                .foregroundColor(Theme.textPrimary)
            
            if let outfit = outfitVM.outfit(for: date) {
                // Outfit photo strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(outfit.allItems) { item in
                            if let fn = item.photoFilename,
                               let image = wardrobeVM.loadPhoto(filename: fn) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(color: Theme.shadowLight, radius: 3, y: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(item.color.color.opacity(0.3))
                                    .frame(width: 60, height: 70)
                                    .overlay(
                                        Image(systemName: item.category.icon)
                                            .font(.caption)
                                            .foregroundColor(item.color.color)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                VStack(spacing: 8) {
                    if let top = outfit.top {
                        historyItemRow(icon: "tshirt.fill", name: top.name, color: top.color)
                    }
                    if let bottom = outfit.bottom {
                        historyItemRow(icon: "rectangle.split.1x2.fill", name: bottom.name, color: bottom.color)
                    }
                    if let foot = outfit.footwear {
                        historyItemRow(icon: "shoeprints.fill", name: foot.name, color: foot.color)
                    }
                    ForEach(outfit.accessories) { acc in
                        historyItemRow(icon: "sparkles", name: acc.name, color: acc.color)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "tshirt")
                        .font(.title2)
                        .foregroundColor(Theme.textMuted.opacity(0.5))
                    Text("No outfit logged")
                        .font(.callout)
                        .foregroundColor(Theme.textMuted)
                    Text("Confirm today's outfit on the Home tab")
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted.opacity(0.7))
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
    
    private func historyItemRow(icon: String, name: String, color: AppColor) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.textMuted)
            Text(name)
                .font(.callout)
                .foregroundColor(Theme.textPrimary)
            Spacer()
            Circle()
                .fill(color.color)
                .frame(width: 16, height: 16)
        }
    }
    
    // MARK: - Profile Card
    
    private var profileCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient.vibrantAccent)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: profileVM.profile.gender.icon)
                        .font(.body)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileVM.profile.name)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text(profileVM.profile.zodiacSign.symbol)
                        Text(profileVM.profile.zodiacSign.rawValue)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        Text("•")
                            .foregroundColor(Theme.textMuted)
                        Text(profileVM.profile.zodiacSign.element)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                profileStat(label: "Items", value: "\(wardrobeVM.items.count)", color: Theme.accentBlue)
                profileStat(label: "Outfits", value: "\(outfitVM.history.count)", color: Theme.accentGreen)
                profileStat(label: "Streak", value: "\(streakCount)", color: Theme.accentOrange)
                profileStat(label: "Body", value: profileVM.profile.bodyType.rawValue, color: Theme.accentPurple)
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private func profileStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.callout.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}
