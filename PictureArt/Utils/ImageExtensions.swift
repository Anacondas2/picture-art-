import UIKit
import CoreGraphics

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func resizedToFit(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: newSize)
    }

    func normalized() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    func paddedToMultiple(rows: Int, cols: Int) -> UIImage {
        let w = Int(size.width)
        let h = Int(size.height)
        let newW = w - (w % cols) + (w % cols == 0 ? 0 : cols)
        let newH = h - (h % rows) + (h % rows == 0 ? 0 : rows)
        guard newW != w || newH != h else { return self }
        let newSize = CGSize(width: newW, height: newH)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: newSize))
            self.draw(in: CGRect(
                x: (newW - w) / 2,
                y: (newH - h) / 2,
                width: w,
                height: h
            ))
        }
    }

    var jpegDataMedium: Data? { jpegData(compressionQuality: 0.82) }
}
