import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

/// Uses Apple Vision framework to extract the clothing/subject from a photo,
/// removing the background for clean 3D model texturing.
class ClothingExtractor {
    
    private static let ciContext = CIContext()
    
    /// Extracts the foreground subject (clothing) from image, removing background.
    /// Uses VNGenerateForegroundInstanceMaskRequest on iOS 17+,
    /// falls back to VNGeneratePersonSegmentationRequest on iOS 15+.
    static func extractClothing(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        if #available(iOS 17.0, *) {
            extractWithInstanceMask(handler: handler, cgImage: cgImage, completion: completion)
        } else {
            extractWithPersonSegmentation(handler: handler, cgImage: cgImage, completion: completion)
        }
    }
    
    /// Synchronous version for use in background threads
    static func extractClothingSync(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        if #available(iOS 17.0, *) {
            return extractWithInstanceMaskSync(handler: handler, cgImage: cgImage)
        } else {
            return extractWithPersonSegSync(handler: handler, cgImage: cgImage)
        }
    }
    
    // MARK: - iOS 17+ Subject Isolation
    
    @available(iOS 17.0, *)
    private static func extractWithInstanceMask(
        handler: VNImageRequestHandler, cgImage: CGImage,
        completion: @escaping (UIImage?) -> Void
    ) {
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
                guard let result = request.results?.first else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                // Generate mask pixelBuffer
                let maskPixelBuffer = try result.generateMaskedImage(
                    ofInstances: result.allInstances,
                    from: handler,
                    croppedToInstancesExtent: false
                )
                
                let ciImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                let extracted = renderToUIImage(ciImage: ciImage, size: CGSize(
                    width: cgImage.width, height: cgImage.height
                ))
                
                DispatchQueue.main.async { completion(extracted) }
            } catch {
                // Fallback to person segmentation
                extractWithPersonSegmentation(handler: handler, cgImage: cgImage, completion: completion)
            }
        }
    }
    
    @available(iOS 17.0, *)
    private static func extractWithInstanceMaskSync(handler: VNImageRequestHandler, cgImage: CGImage) -> UIImage? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            
            let maskPixelBuffer = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: false
            )
            
            let ciImage = CIImage(cvPixelBuffer: maskPixelBuffer)
            return renderToUIImage(ciImage: ciImage, size: CGSize(
                width: cgImage.width, height: cgImage.height
            ))
        } catch {
            return extractWithPersonSegSync(handler: handler, cgImage: cgImage)
        }
    }
    
    // MARK: - iOS 15+ Person Segmentation Fallback
    
    private static func extractWithPersonSegmentation(
        handler: VNImageRequestHandler, cgImage: CGImage,
        completion: @escaping (UIImage?) -> Void
    ) {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                let mask = result.pixelBuffer
                let extracted = applyMask(mask, to: cgImage)
                DispatchQueue.main.async { completion(extracted) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    private static func extractWithPersonSegSync(handler: VNImageRequestHandler, cgImage: CGImage) -> UIImage? {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            return applyMask(result.pixelBuffer, to: cgImage)
        } catch {
            return nil
        }
    }
    
    // MARK: - Mask Application
    
    /// Applies a segmentation mask to the original image, making background transparent
    private static func applyMask(_ maskBuffer: CVPixelBuffer, to cgImage: CGImage) -> UIImage? {
        let originalCI = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cvPixelBuffer: maskBuffer)
        
        // Scale mask to match original image size
        let scaleX = originalCI.extent.width / maskCI.extent.width
        let scaleY = originalCI.extent.height / maskCI.extent.height
        let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Apply mask: blend original with transparent using mask
        let filter = CIFilter.blendWithMask()
        filter.inputImage = originalCI
        filter.backgroundImage = CIImage.empty()
        filter.maskImage = scaledMask
        
        guard let output = filter.outputImage else { return nil }
        
        return renderToUIImage(ciImage: output, size: CGSize(
            width: cgImage.width, height: cgImage.height
        ))
    }
    
    // MARK: - Render
    
    private static func renderToUIImage(ciImage: CIImage, size: CGSize) -> UIImage? {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
