import SwiftUI

// MARK: - Gradient Presets

extension LinearGradient {
    static let cosmicDark = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.02, blue: 0.15),
            Color(red: 0.08, green: 0.05, blue: 0.25),
            Color(red: 0.05, green: 0.02, blue: 0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cosmicAccent = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.2, blue: 0.8),
            Color(red: 0.6, green: 0.3, blue: 0.9)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let goldenHour = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.75, blue: 0.3),
            Color(red: 1.0, green: 0.5, blue: 0.2)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Color.white
                        .opacity(0.2)
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white, .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * 0.4)
                                .offset(x: -geo.size.width * 0.2 + phase * (geo.size.width * 1.4))
                        )
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Star Background

struct StarField: View {
    let starCount: Int
    @State private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
    
    init(count: Int = 50) {
        self.starCount = count
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<stars.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: stars[i].size, height: stars[i].size)
                        .position(x: stars[i].x * geo.size.width, y: stars[i].y * geo.size.height)
                        .opacity(stars[i].opacity)
                }
            }
            .onAppear {
                stars = (0..<starCount).map { _ in
                    (
                        x: CGFloat.random(in: 0...1),
                        y: CGFloat.random(in: 0...1),
                        size: CGFloat.random(in: 1...3),
                        opacity: Double.random(in: 0.2...0.8)
                    )
                }
            }
        }
    }
}

// MARK: - Cosmic Background

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient.cosmicDark
            StarField(count: 60)
        }
        .ignoresSafeArea()
    }
}
