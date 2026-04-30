import SwiftUI

struct LuckyColorBanner: View {
    let colors: [AppColor]
    let planet: (name: String, symbol: String)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(planet.symbol)
                    .font(.title3)
                Text("Ruled by \(planet.name)")
                    .font(.callout.weight(.medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(colors.prefix(6)), id: \.self) { appColor in
                        VStack(spacing: 6) {
                            Circle()
                                .fill(appColor.color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                                .shadow(color: appColor.color.opacity(0.5), radius: 8)
                            
                            Text(appColor.displayName)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .glassCard()
    }
}
