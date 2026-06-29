import UIKit
import CoreGraphics

struct ImageSplitter {
    func split(image: UIImage, rows: Int, cols: Int) -> [[UIImage]] {
        let normalized = image.normalized()
        let padded = normalized.paddedToMultiple(rows: rows, cols: cols)

        guard let cgImage = padded.cgImage else { return [] }

        let totalW = cgImage.width
        let totalH = cgImage.height
        let tileW = totalW / cols
        let tileH = totalH / rows

        var result: [[UIImage]] = []

        for row in 0..<rows {
            var rowTiles: [UIImage] = []
            for col in 0..<cols {
                let rect = CGRect(
                    x: col * tileW,
                    y: row * tileH,
                    width: tileW,
                    height: tileH
                )
                if let tile = cgImage.cropping(to: rect) {
                    rowTiles.append(UIImage(cgImage: tile, scale: padded.scale, orientation: .up))
                }
            }
            result.append(rowTiles)
        }

        return result
    }
}
