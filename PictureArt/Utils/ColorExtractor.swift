import UIKit
import CoreGraphics

struct ColorExtractor {
    func dominantColors(in image: UIImage, count: Int = 6) -> [UIColor] {
        guard let cgImage = image.normalized().cgImage else { return [] }

        let thumbSize = 60
        let bytesPerPixel = 4
        let bytesPerRow = thumbSize * bytesPerPixel
        var rawData = [UInt8](repeating: 0, count: thumbSize * bytesPerRow)

        guard let context = CGContext(
            data: &rawData,
            width: thumbSize,
            height: thumbSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))

        // Bucket size: 32 levels per channel → 8 buckets per channel
        var buckets: [Int32: (count: Int, r: Int, g: Int, b: Int)] = [:]

        for y in 0..<thumbSize {
            for x in 0..<thumbSize {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let r = Int(rawData[offset])
                let g = Int(rawData[offset + 1])
                let b = Int(rawData[offset + 2])
                let a = Int(rawData[offset + 3])
                guard a > 128 else { continue }

                let rB = Int32(r / 32)
                let gB = Int32(g / 32)
                let bB = Int32(b / 32)
                let key = rB * 64 + gB * 8 + bB

                if let existing = buckets[key] {
                    buckets[key] = (existing.count + 1, existing.r + r, existing.g + g, existing.b + b)
                } else {
                    buckets[key] = (1, r, g, b)
                }
            }
        }

        let sorted = buckets.values.sorted { $0.count > $1.count }
        return sorted.prefix(count).map { entry in
            UIColor(
                red: CGFloat(entry.r / entry.count) / 255.0,
                green: CGFloat(entry.g / entry.count) / 255.0,
                blue: CGFloat(entry.b / entry.count) / 255.0,
                alpha: 1.0
            )
        }
    }
}
