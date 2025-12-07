import SwiftUI
import AppKit

enum CornerRadius: Equatable {
    case preset(Int)
    case custom(Int)
    
    var value: Int {
        switch self {
        case .preset(let val), .custom(let val):
            return val
        }
    }
}

class IconGeneratorViewModel: ObservableObject {
    @Published var sourceImage: NSImage?
    @Published var selectedRadius: CornerRadius = .preset(0)
    @Published var customRadius: Int = 0
    @Published var isGenerating: Bool = false
    @Published var outputPath: URL?
    @Published var statusMessage: String?
    @Published var isError: Bool = false
    @Published var generateLogo: Bool = false
    
    // iOS App Icon sizes according to Apple's guidelines
    let iconSizes: [(size: Int, scale: Int, idiom: String, filename: String)] = [
        // iPhone
        (20, 2, "iphone", "Icon-20@2x.png"),
        (20, 3, "iphone", "Icon-20@3x.png"),
        (29, 2, "iphone", "Icon-29@2x.png"),
        (29, 3, "iphone", "Icon-29@3x.png"),
        (40, 2, "iphone", "Icon-40@2x.png"),
        (40, 3, "iphone", "Icon-40@3x.png"),
        (60, 2, "iphone", "Icon-60@2x.png"),
        (60, 3, "iphone", "Icon-60@3x.png"),
        
        // iPad
        (20, 1, "ipad", "Icon-20.png"),
        (20, 2, "ipad", "Icon-20@2x.png"),
        (29, 1, "ipad", "Icon-29.png"),
        (29, 2, "ipad", "Icon-29@2x.png"),
        (40, 1, "ipad", "Icon-40.png"),
        (40, 2, "ipad", "Icon-40@2x.png"),
        (76, 1, "ipad", "Icon-76.png"),
        (76, 2, "ipad", "Icon-76@2x.png"),
        (83, 2, "ipad", "Icon-83.5@2x.png"),
        
        // App Store
        (1024, 1, "ios-marketing", "Icon-1024.png"),
    ]
    
    func generateIcons() {
        guard let sourceImage = sourceImage else { return }
        
        isGenerating = true
        isError = false
        statusMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Create output directory
                let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
                let timestamp = Int(Date().timeIntervalSince1970)
                let outputDir = desktopURL.appendingPathComponent("AppIcon.appiconset_\(timestamp)")
                try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
                
                // Generate all icon sizes
                var contentsJSON: [String: Any] = ["images": [], "info": ["version": 1, "author": "xcode"]]
                var images: [[String: Any]] = []
                
                for iconConfig in self.iconSizes {
                    let pixelSize = iconConfig.size * iconConfig.scale
                    let filename = iconConfig.filename
                    
                    if let resizedImage = self.resizeImage(sourceImage, to: CGSize(width: pixelSize, height: pixelSize)) {
                        let finalImage = self.applyCornerRadius(to: resizedImage, radius: self.selectedRadius.value)
                        let outputURL = outputDir.appendingPathComponent(filename)
                        
                        if self.saveImage(finalImage, to: outputURL) {
                            var imageInfo: [String: Any] = [
                                "filename": filename,
                                "idiom": iconConfig.idiom,
                                "size": "\(iconConfig.size)x\(iconConfig.size)"
                            ]
                            
                            if iconConfig.scale > 1 {
                                imageInfo["scale"] = "\(iconConfig.scale)x"
                            } else {
                                imageInfo["scale"] = "1x"
                            }
                            
                            images.append(imageInfo)
                        }
                    }
                }
                
                contentsJSON["images"] = images
                
                // Save Contents.json
                let contentsURL = outputDir.appendingPathComponent("Contents.json")
                let jsonData = try JSONSerialization.data(withJSONObject: contentsJSON, options: .prettyPrinted)
                try jsonData.write(to: contentsURL)
                
                // Generate Logo.imageset if option is enabled
                var logoGenerated = false
                if self.generateLogo {
                    logoGenerated = self.generateLogoImageset(sourceImage: sourceImage, outputDir: desktopURL)
                }
                
                DispatchQueue.main.async {
                    self.outputPath = outputDir
                    self.isGenerating = false
                    var message = "✓ Successfully generated \(self.iconSizes.count) icons!"
                    if logoGenerated {
                        message += "\n✓ Logo.imageset created!"
                    }
                    self.statusMessage = message
                    self.isError = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.isError = true
                }
            }
        }
    }
    
    private func resizeImage(_ image: NSImage, to size: CGSize) -> NSImage? {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
    
    private func applyCornerRadius(to image: NSImage, radius: Int) -> NSImage {
        guard radius > 0 else { return image }
        
        let size = image.size
        let cornerRadius = CGFloat(radius)
        
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        
        let rect = NSRect(origin: .zero, size: size)
        let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
        path.addClip()
        
        image.draw(at: .zero, from: rect, operation: .sourceOver, fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
    
    private func saveImage(_ image: NSImage, to url: URL) -> Bool {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return false
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return false
        }
        
        do {
            try pngData.write(to: url)
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }
    
    private func generateLogoImageset(sourceImage: NSImage, outputDir: URL) -> Bool {
        do {
            let timestamp = Int(Date().timeIntervalSince1970)
            let logoDir = outputDir.appendingPathComponent("Logo.imageset_\(timestamp)")
            try FileManager.default.createDirectory(at: logoDir, withIntermediateDirectories: true)
            
            // Generate logo in 3 sizes: @1x, @2x, @3x
            let logoSizes: [(scale: Int, size: Int, filename: String)] = [
                (1, 60, "Logo.png"),
                (2, 120, "Logo@2x.png"),
                (3, 180, "Logo@3x.png")
            ]
            
            var images: [[String: Any]] = []
            
            for logoConfig in logoSizes {
                let size = CGSize(width: logoConfig.size, height: logoConfig.size)
                if let resizedImage = self.resizeImage(sourceImage, to: size) {
                    let finalImage = self.applyCornerRadius(to: resizedImage, radius: self.selectedRadius.value)
                    let outputURL = logoDir.appendingPathComponent(logoConfig.filename)
                    
                    if self.saveImage(finalImage, to: outputURL) {
                        images.append([
                            "filename": logoConfig.filename,
                            "idiom": "universal",
                            "scale": "\(logoConfig.scale)x"
                        ])
                    }
                }
            }
            
            // Create Contents.json for Logo.imageset
            let logoContents: [String: Any] = [
                "images": images,
                "info": [
                    "version": 1,
                    "author": "xcode"
                ]
            ]
            
            let logoContentsURL = logoDir.appendingPathComponent("Contents.json")
            let logoJsonData = try JSONSerialization.data(withJSONObject: logoContents, options: .prettyPrinted)
            try logoJsonData.write(to: logoContentsURL)
            
            return true
        } catch {
            print("Error generating logo imageset: \(error)")
            return false
        }
    }
    
    func revealInFinder() {
        guard let outputPath = outputPath else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputPath.path)
    }
}
