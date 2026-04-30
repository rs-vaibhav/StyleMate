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
                        .foregroundColor(.white)
                    
                    if streakCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(streakCount) day streak!")
                                .font(.callout.weight(.semibold))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
                .padding(.top, 16)
                
                // Month Label
                Text(currentMonth)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
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
                        .foregroundColor(.white.opacity(0.4))
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
                                        .foregroundColor(isToday ? .white : .white.opacity(0.7))
                                    
                                    if hasOutfit {
                                        Circle()
                                            .fill(Color(red: 0.6, green: 0.3, blue: 0.9))
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
                                        ? Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.3)
                                        : isToday
                                            ? Color.white.opacity(0.08)
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
                .foregroundColor(.white)
            
            if let outfit = outfitVM.outfit(for: date) {
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
                Text("No outfit logged for this day")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.4))
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
                .foregroundColor(.white.opacity(0.5))
            Text(name)
                .font(.callout)
                .foregroundColor(.white)
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
                Image(systemName: profileVM.profile.gender.icon)
                    .font(.title)
                    .foregroundStyle(LinearGradient.cosmicAccent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileVM.profile.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text(profileVM.profile.zodiacSign.symbol)
                        Text(profileVM.profile.zodiacSign.rawValue)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        Text("•")
                            .foregroundColor(.white.opacity(0.3))
                        Text(profileVM.profile.zodiacSign.element)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack {
                profileStat(label: "Items", value: "\(wardrobeVM.items.count)")
                profileStat(label: "Outfits", value: "\(outfitVM.history.count)")
                profileStat(label: "Streak", value: "\(streakCount)")
                profileStat(label: "Body", value: profileVM.profile.bodyType.rawValue)
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private func profileStat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.callout.weight(.bold))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}
