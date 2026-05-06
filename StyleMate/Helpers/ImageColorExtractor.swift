import UIKit
import SwiftUI

/// Extracts the dominant color from an image using pixel sampling — no ML needed.
struct ImageColorExtractor {
    
    /// Extracts the dominant AppColor from a UIImage by sampling center pixels.
    static func dominantAppColor(from image: UIImage) -> AppColor {
        let dominant = dominantUIColor(from: image)
        return closestAppColor(to: dominant)
    }
    
    /// Auto-generates a name for the wardrobe item based on detected color + category.
    static func autoName(color: AppColor, category: ClothingCategory) -> String {
        "\(color.displayName) \(category.rawValue)"
    }
    
    // MARK: - Dominant Color Extraction
    
    /// Samples pixels from the center region of the image to find dominant color.
    static func dominantUIColor(from image: UIImage) -> UIColor {
        guard let cgImage = image.cgImage else { return .gray }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Sample from center 60% of image to avoid background edges
        let sampleX = Int(Double(width) * 0.2)
        let sampleY = Int(Double(height) * 0.2)
        let sampleW = Int(Double(width) * 0.6)
        let sampleH = Int(Double(height) * 0.6)
        
        guard sampleW > 0, sampleH > 0 else { return .gray }
        
        // Create a small bitmap context to read pixels
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Downsample to 20x20 for speed
        let thumbSize = 20
        guard let context = CGContext(
            data: nil,
            width: thumbSize,
            height: thumbSize,
            bitsPerComponent: 8,
            bytesPerRow: thumbSize * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return .gray }
        
        // Draw the center crop into thumbnail
        if let cropped = cgImage.cropping(to: CGRect(x: sampleX, y: sampleY, width: sampleW, height: sampleH)) {
            context.draw(cropped, in: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
        }
        
        guard let data = context.data else { return .gray }
        let pointer = data.bindMemory(to: UInt8.self, capacity: thumbSize * thumbSize * 4)
        
        var totalR: Double = 0
        var totalG: Double = 0
        var totalB: Double = 0
        var count: Double = 0
        
        for y in 0..<thumbSize {
            for x in 0..<thumbSize {
                let offset = (y * thumbSize + x) * 4
                let r = Double(pointer[offset]) / 255.0
                let g = Double(pointer[offset + 1]) / 255.0
                let b = Double(pointer[offset + 2]) / 255.0
                
                // Skip very bright (white background) and very dark pixels
                let brightness = (r + g + b) / 3.0
                if brightness > 0.92 || brightness < 0.05 { continue }
                
                totalR += r
                totalG += g
                totalB += b
                count += 1
            }
        }
        
        guard count > 0 else { return .gray }
        
        return UIColor(
            red: totalR / count,
            green: totalG / count,
            blue: totalB / count,
            alpha: 1.0
        )
    }
    
    // MARK: - Closest AppColor Match
    
    /// Finds the closest AppColor to the given UIColor using color distance.
    static func closestAppColor(to uiColor: UIColor) -> AppColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var bestMatch: AppColor = .grey
        var bestDistance: Double = .infinity
        
        for appColor in AppColor.allCases {
            let swiftColor = appColor.color
            let components = UIColor(swiftColor)
            var cr: CGFloat = 0, cg: CGFloat = 0, cb: CGFloat = 0, ca: CGFloat = 0
            components.getRed(&cr, green: &cg, blue: &cb, alpha: &ca)
            
            // Weighted Euclidean distance (human eye is more sensitive to green)
            let dr = Double(r - cr)
            let dg = Double(g - cg)
            let db = Double(b - cb)
            let distance = (dr * dr * 0.3) + (dg * dg * 0.59) + (db * db * 0.11)
            
            if distance < bestDistance {
                bestDistance = distance
                bestMatch = appColor
            }
        }
        
        return bestMatch
    }
}
