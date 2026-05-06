import SwiftUI

// MARK: - Theme Colors

struct Theme {
    // Primary backgrounds
    static let background = Color(red: 0.96, green: 0.97, blue: 1.0)
    static let cardBackground = Color.white
    static let cardBorder = Color(red: 0.90, green: 0.92, blue: 0.96)
    
    // Accent colors — Subway Surfers inspired
    static let accentRed = Color(red: 0.93, green: 0.26, blue: 0.26)
    static let accentBlue = Color(red: 0.30, green: 0.60, blue: 0.98)
    static let accentGreen = Color(red: 0.22, green: 0.80, blue: 0.46)
    static let accentYellow = Color(red: 1.0, green: 0.82, blue: 0.15)
    static let accentOrange = Color(red: 1.0, green: 0.55, blue: 0.20)
    static let accentPink = Color(red: 0.96, green: 0.40, blue: 0.56)
    static let accentPurple = Color(red: 0.56, green: 0.35, blue: 0.95)
    
    // Text colors
    static let textPrimary = Color(red: 0.12, green: 0.14, blue: 0.20)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.55)
    static let textMuted = Color(red: 0.65, green: 0.68, blue: 0.72)
    
    // Shadows
    static let shadowLight = Color.black.opacity(0.06)
    static let shadowMedium = Color.black.opacity(0.10)
}

// MARK: - Gradient Presets

extension LinearGradient {
    static let vibrantAccent = LinearGradient(
        colors: [
            Theme.accentRed,
            Theme.accentOrange
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let freshGreen = LinearGradient(
        colors: [
            Theme.accentGreen,
            Color(red: 0.10, green: 0.70, blue: 0.55)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let skyBlue = LinearGradient(
        colors: [
            Theme.accentBlue,
            Color(red: 0.40, green: 0.72, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunshineYellow = LinearGradient(
        colors: [
            Theme.accentYellow,
            Theme.accentOrange
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let vibrantHero = LinearGradient(
        colors: [
            Theme.accentRed,
            Theme.accentOrange,
            Theme.accentYellow
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Keep backward compatibility names
    static let cosmicAccent = vibrantAccent
    static let goldenHour = sunshineYellow
}

// MARK: - Light Card Modifier

struct LightCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var elevated: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
            .shadow(color: elevated ? Theme.shadowMedium : Theme.shadowLight, radius: elevated ? 12 : 6, x: 0, y: elevated ? 6 : 3)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(LightCard(cornerRadius: cornerRadius))
    }
    
    func elevatedCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(LightCard(cornerRadius: cornerRadius, elevated: true))
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
                        .opacity(0.3)
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

// MARK: - Floating Shapes Background

struct FloatingShape: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var shapeType: Int // 0 = circle, 1 = rounded rect, 2 = capsule
    var opacity: Double
    var rotation: Double
}

struct FloatingShapesView: View {
    @State private var shapes: [FloatingShape] = []
    @State private var animate = false
    
    let shapeColors: [Color] = [
        Theme.accentRed.opacity(0.08),
        Theme.accentBlue.opacity(0.08),
        Theme.accentGreen.opacity(0.08),
        Theme.accentYellow.opacity(0.10),
        Theme.accentOrange.opacity(0.06),
        Theme.accentPink.opacity(0.06),
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(shapes) { shape in
                    Group {
                        switch shape.shapeType {
                        case 0:
                            Circle()
                                .fill(shape.color)
                        case 1:
                            RoundedRectangle(cornerRadius: shape.size * 0.2)
                                .fill(shape.color)
                        default:
                            Capsule()
                                .fill(shape.color)
                        }
                    }
                    .frame(width: shape.size, height: shape.shapeType == 2 ? shape.size * 0.5 : shape.size)
                    .position(
                        x: shape.x * geo.size.width + (animate ? 15 : -15),
                        y: shape.y * geo.size.height + (animate ? -10 : 10)
                    )
                    .rotationEffect(.degrees(animate ? shape.rotation + 20 : shape.rotation))
                    .opacity(shape.opacity)
                }
            }
            .onAppear {
                generateShapes()
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }
    
    private func generateShapes() {
        shapes = (0..<15).map { _ in
            FloatingShape(
                x: CGFloat.random(in: 0.05...0.95),
                y: CGFloat.random(in: 0.05...0.95),
                size: CGFloat.random(in: 30...100),
                color: shapeColors.randomElement() ?? Theme.accentBlue.opacity(0.08),
                shapeType: Int.random(in: 0...2),
                opacity: Double.random(in: 0.3...0.8),
                rotation: Double.random(in: 0...360)
            )
        }
    }
}

// MARK: - Vibrant Background (replaces CosmicBackground)

struct VibrantBackground: View {
    var body: some View {
        ZStack {
            Theme.background
            FloatingShapesView()
        }
        .ignoresSafeArea()
    }
}

// Keep backward compatibility
struct CosmicBackground: View {
    var body: some View {
        VibrantBackground()
    }
}

// MARK: - Bouncy Button Style

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func bouncyButton() -> some View {
        buttonStyle(BouncyButtonStyle())
    }
}
