import SwiftUI

/// Premium 2D outfit visualization — clothing photos layered on a clean mannequin silhouette.
/// Replaces the ugly 3D SceneKit view with a beautiful, polished outfit board.
struct OutfitBoardView: View {
    let topImage: UIImage?
    let bottomImage: UIImage?
    let footwearImage: UIImage?
    let topColor: Color?
    let bottomColor: Color?
    let footwearColor: Color?
    let accessoryColor: Color?
    
    @State private var parallaxX: CGFloat = 0
    @State private var parallaxY: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.97, blue: 0.99),
                        Color(red: 0.91, green: 0.93, blue: 0.97)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                
                // Subtle grid pattern
                gridPattern(in: geo.size)
                    .opacity(0.04)
                
                // Mannequin silhouette (subtle background guide)
                mannequinSilhouette
                    .fill(Color.gray.opacity(0.06))
                    .frame(width: w * 0.45, height: h * 0.85)
                    .offset(x: parallaxX * 0.02, y: parallaxY * 0.02)
                
                // Clothing layers
                VStack(spacing: 0) {
                    // Head placeholder (small circle)
                    Circle()
                        .fill(Color(red: 0.85, green: 0.72, blue: 0.58).opacity(0.6))
                        .frame(width: w * 0.10, height: w * 0.10)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        .offset(x: parallaxX * 0.05, y: parallaxY * 0.05)
                    
                    Spacer().frame(height: 6)
                    
                    // TOP — clothing photo
                    clothingCard(
                        image: topImage,
                        fallbackColor: topColor ?? .gray,
                        icon: "tshirt.fill",
                        width: w * 0.52,
                        height: h * 0.32,
                        cornerRadius: 16,
                        shadowColor: .black.opacity(0.12)
                    )
                    .offset(x: parallaxX * 0.08, y: parallaxY * 0.06)
                    
                    Spacer().frame(height: 6)
                    
                    // BOTTOM — clothing photo
                    clothingCard(
                        image: bottomImage,
                        fallbackColor: bottomColor ?? Color(red: 0.15, green: 0.15, blue: 0.30),
                        icon: "rectangle.split.1x2.fill",
                        width: w * 0.40,
                        height: h * 0.34,
                        cornerRadius: 14,
                        shadowColor: .black.opacity(0.10)
                    )
                    .offset(x: parallaxX * 0.06, y: parallaxY * 0.04)
                    
                    Spacer().frame(height: 6)
                    
                    // FOOTWEAR
                    HStack(spacing: w * 0.04) {
                        clothingCard(
                            image: footwearImage,
                            fallbackColor: footwearColor ?? Color(red: 0.12, green: 0.12, blue: 0.12),
                            icon: "shoeprints.fill",
                            width: w * 0.18,
                            height: h * 0.10,
                            cornerRadius: 10,
                            shadowColor: .black.opacity(0.08)
                        )
                        clothingCard(
                            image: footwearImage,
                            fallbackColor: footwearColor ?? Color(red: 0.12, green: 0.12, blue: 0.12),
                            icon: "shoeprints.fill",
                            width: w * 0.18,
                            height: h * 0.10,
                            cornerRadius: 10,
                            shadowColor: .black.opacity(0.08)
                        )
                        .scaleEffect(x: -1, y: 1) // Mirror for right shoe
                    }
                    .offset(x: parallaxX * 0.04, y: parallaxY * 0.03)
                }
                .padding(.top, h * 0.02)
                .padding(.bottom, h * 0.02)
                
                // Accessory accent (belt/watch indicator)
                if let accColor = accessoryColor {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(accColor)
                        .frame(width: w * 0.35, height: 5)
                        .shadow(color: accColor.opacity(0.4), radius: 4)
                        .position(x: w/2, y: h * 0.52)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        withAnimation(.interactiveSpring()) {
                            parallaxX = (val.location.x - w/2) / w * 15
                            parallaxY = (val.location.y - h/2) / h * 10
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            parallaxX = 0
                            parallaxY = 0
                        }
                    }
            )
        }
    }
    
    // MARK: - Clothing Card
    
    @ViewBuilder
    private func clothingCard(
        image: UIImage?, fallbackColor: Color, icon: String,
        width: CGFloat, height: CGFloat, cornerRadius: CGFloat,
        shadowColor: Color
    ) -> some View {
        if let img = image {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [fallbackColor.opacity(0.7), fallbackColor],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: height)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: min(width, height) * 0.25))
                        .foregroundColor(.white.opacity(0.3))
                )
                .shadow(color: shadowColor, radius: 6, x: 0, y: 3)
        }
    }
    
    // MARK: - Mannequin Silhouette
    
    private var mannequinSilhouette: Path {
        Path { p in
            // Simple human outline
            let cx: CGFloat = 0.5
            // Head
            p.addEllipse(in: CGRect(x: cx - 0.05, y: 0.01, width: 0.10, height: 0.10))
            // Neck
            p.addRect(CGRect(x: cx - 0.02, y: 0.10, width: 0.04, height: 0.04))
            // Torso
            p.move(to: CGPoint(x: cx - 0.20, y: 0.14))
            p.addLine(to: CGPoint(x: cx + 0.20, y: 0.14))
            p.addLine(to: CGPoint(x: cx + 0.16, y: 0.48))
            p.addLine(to: CGPoint(x: cx - 0.16, y: 0.48))
            p.closeSubpath()
            // Left leg
            p.addRect(CGRect(x: cx - 0.14, y: 0.49, width: 0.12, height: 0.40))
            // Right leg
            p.addRect(CGRect(x: cx + 0.02, y: 0.49, width: 0.12, height: 0.40))
        }
    }
    
    // MARK: - Grid Pattern
    
    private func gridPattern(in size: CGSize) -> some View {
        Canvas { ctx, canvasSize in
            let spacing: CGFloat = 20
            for x in stride(from: 0, through: canvasSize.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                ctx.stroke(path, with: .color(.gray), lineWidth: 0.5)
            }
            for y in stride(from: 0, through: canvasSize.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                ctx.stroke(path, with: .color(.gray), lineWidth: 0.5)
            }
        }
    }
}
