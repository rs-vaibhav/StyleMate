import SwiftUI

struct BodySilhouetteView: View {
    var topColor: Color
    var bottomColor: Color
    var footwearColor: Color
    var accessoryColor: Color?
    
    var body: some View {
        ZStack {
            // Glow background
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [topColor.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 400)
            
            VStack(spacing: 0) {
                // Head
                Circle()
                    .fill(Color(red: 0.85, green: 0.72, blue: 0.58))
                    .frame(width: 36, height: 36)
                
                // Neck
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.72, blue: 0.58))
                    .frame(width: 14, height: 8)
                
                // Top (Torso)
                ZStack {
                    // Body
                    TorsoShape()
                        .fill(topColor)
                        .frame(width: 90, height: 85)
                    
                    // Collar detail
                    Path { path in
                        path.move(to: CGPoint(x: 35, y: 0))
                        path.addLine(to: CGPoint(x: 45, y: 12))
                        path.addLine(to: CGPoint(x: 55, y: 0))
                    }
                    .stroke(topColor == .white ? Color.gray.opacity(0.3) : Color.white.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 90, height: 85)
                }
                
                // Belt / Accessory
                if let accColor = accessoryColor {
                    Rectangle()
                        .fill(accColor)
                        .frame(width: 80, height: 6)
                        .clipShape(Capsule())
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 4)
                        .clipShape(Capsule())
                }
                
                // Bottom (Legs)
                HStack(spacing: 4) {
                    LegShape()
                        .fill(bottomColor)
                        .frame(width: 34, height: 100)
                    
                    LegShape()
                        .fill(bottomColor)
                        .frame(width: 34, height: 100)
                }
                
                // Footwear
                HStack(spacing: 12) {
                    ShoeShape()
                        .fill(footwearColor)
                        .frame(width: 38, height: 16)
                    
                    ShoeShape()
                        .fill(footwearColor)
                        .frame(width: 38, height: 16)
                        .scaleEffect(x: -1, y: 1)
                }
            }
        }
        .frame(height: 280)
    }
}

// MARK: - Custom Shapes

struct TorsoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Shoulders to waist
        path.move(to: CGPoint(x: w * 0.35, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.25, y: h))
        path.addLine(to: CGPoint(x: w * 0.75, y: h))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.35))
        path.addLine(to: CGPoint(x: w, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.65, y: 0))
        path.closeSubpath()
        
        return path
    }
}

struct LegShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.1, y: 0))
        path.addLine(to: CGPoint(x: w * 0.05, y: h))
        path.addLine(to: CGPoint(x: w * 0.95, y: h))
        path.addLine(to: CGPoint(x: w * 0.9, y: 0))
        path.closeSubpath()
        
        return path
    }
}

struct ShoeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.15, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h * 0.5))
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control: CGPoint(x: w * 0.5, y: h * 1.2)
        )
        path.addLine(to: CGPoint(x: w * 0.85, y: 0))
        path.closeSubpath()
        
        return path
    }
}
