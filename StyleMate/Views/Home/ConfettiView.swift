import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var xSpeed: CGFloat
    var ySpeed: CGFloat
    var scale: CGFloat
    var rotation: Double
    var color: Color
    var spinSpeed: Double
}

struct ConfettiView: View {
    @Binding var isTriggered: Bool
    @State private var particles: [ConfettiParticle] = []
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: 8, height: 16)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                        .rotation3DEffect(.degrees(particle.rotation), axis: (x: 1, y: 1, z: 0))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onChange(of: isTriggered) { triggered in
                if triggered {
                    fireConfetti(in: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func fireConfetti(in size: CGSize) {
        // Create initial particles at the center bottom
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: size.width / 2,
                y: size.height / 2,
                xSpeed: CGFloat.random(in: -15...15),
                ySpeed: CGFloat.random(in: -25 ... -10),
                scale: CGFloat.random(in: 0.5...1.5),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                spinSpeed: Double.random(in: -20...20)
            )
        }
        
        // Animate physics
        let displayLink = CADisplayLink(target: ParticleAnimator(update: updateParticles), selector: #selector(ParticleAnimator.tick))
        displayLink.add(to: .main, forMode: .common)
        
        // Stop after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            displayLink.invalidate()
            particles = []
            isTriggered = false
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            // Apply gravity
            particles[i].ySpeed += 0.5
            // Apply air resistance
            particles[i].xSpeed *= 0.98
            
            // Move
            particles[i].x += particles[i].xSpeed
            particles[i].y += particles[i].ySpeed
            
            // Spin
            particles[i].rotation += particles[i].spinSpeed
        }
    }
}

class ParticleAnimator {
    let update: () -> Void
    init(update: @escaping () -> Void) {
        self.update = update
    }
    @objc func tick() {
        update()
    }
}
