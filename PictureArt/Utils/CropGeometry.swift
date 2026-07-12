import CoreGraphics
import Foundation

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Crop geometry (pure, testable, view-free)
//  All math lives here in oriented image POINTS; the persistent
//  model is a normalized region, independent of any screen.
//  Reserved (documented, not built): quarter-turn rotation hook.
// ═══════════════════════════════════════════════════════════════

/// Target aspect for the crop frame. `.custom` is the Paper-stage hook:
/// a future canvas can supply any positive width/height ratio.
enum CropAspect: Equatable {
    case original
    case aSeriesPortrait     // 1 : 1.414
    case aSeriesLandscape    // 1.414 : 1
    case square
    case custom(CGFloat)     // width / height

    func ratio(for sourceSize: CGSize) -> CGFloat {
        switch self {
        case .original:
            return sourceSize.height > 0 ? sourceSize.width / sourceSize.height : 1
        case .aSeriesPortrait:  return 1 / 1.414
        case .aSeriesLandscape: return 1.414
        case .square:           return 1
        case .custom(let r):    return Swift.max(r, 0.0001)
        }
    }
}

/// The persistent, viewport-independent framing.
/// Invariants: region ⊆ unit rect, area > 0, region aspect matches
/// the target aspect within epsilon (in source proportions).
struct CropConfiguration: Equatable {
    var region: CGRect          // normalized [0,1]², oriented-image space
    var aspect: CropAspect
    let sourceSize: CGSize      // oriented pixels — identity + validation

    /// Default framing: centered, maximum coverage for the aspect.
    static func full(for sourceSize: CGSize, aspect: CropAspect) -> CropConfiguration {
        let target = aspect.ratio(for: sourceSize)
        let srcRatio = sourceSize.width / Swift.max(sourceSize.height, 1)
        var w: CGFloat = 1, h: CGFloat = 1
        if srcRatio > target {
            w = target / srcRatio      // source is wider — crop width
        } else if srcRatio < target {
            h = srcRatio / target      // source is taller — crop height
        }
        return CropConfiguration(
            region: CGRect(x: (1 - w) / 2, y: (1 - h) / 2, width: w, height: h),
            aspect: aspect,
            sourceSize: sourceSize
        )
    }

    /// Same aspect coverage, but centered on a carried-over focal point.
    static func full(for sourceSize: CGSize, aspect: CropAspect, focus: CGPoint) -> CropConfiguration {
        var c = full(for: sourceSize, aspect: aspect)
        var r = c.region
        r.origin.x = Swift.min(Swift.max(focus.x - r.width / 2, 0), 1 - r.width)
        r.origin.y = Swift.min(Swift.max(focus.y - r.height / 2, 0), 1 - r.height)
        c.region = r
        return c
    }
}

enum CropGeometry {

    /// Minimum visible short side of the crop, in source pixels.
    /// Protects usability without restricting legitimate composition.
    static let minVisiblePixels: CGFloat = 192

    /// Fill base scale: image completely covers the frame at zoom 1.
    static func baseScale(image: CGSize, frame: CGSize) -> CGFloat {
        Swift.max(frame.width / Swift.max(image.width, 1),
                  frame.height / Swift.max(image.height, 1))
    }

    static let minZoom: CGFloat = 1

    /// Resolution-aware ceiling: never zoom past the point where the
    /// visible region's short side would fall under `minVisiblePixels`,
    /// hard-capped at 6×.
    static func maxZoom(imagePoints: CGSize, pixelScale: CGFloat, frame: CGSize) -> CGFloat {
        let base = baseScale(image: imagePoints, frame: frame)
        guard base > 0 else { return 1 }
        let resBound = (Swift.min(frame.width, frame.height) * Swift.max(pixelScale, 0.0001))
                     / (minVisiblePixels * base)
        return Swift.max(1, Swift.min(6, resBound))
    }

    /// Keep the frame fully covered: |offset| ≤ (displayed − frame) / 2.
    static func clampOffset(_ offset: CGSize, image: CGSize, frame: CGSize, zoom: CGFloat) -> CGSize {
        let s = baseScale(image: image, frame: frame) * zoom
        let maxX = Swift.max(0, (image.width  * s - frame.width)  / 2)
        let maxY = Swift.max(0, (image.height * s - frame.height) / 2)
        return CGSize(width:  Swift.min(maxX, Swift.max(-maxX, offset.width)),
                      height: Swift.min(maxY, Swift.max(-maxY, offset.height)))
    }

    /// Viewport → persistent region (commit after a gesture ends).
    static func region(zoom: CGFloat, offset: CGSize, image: CGSize, frame: CGSize) -> CGRect {
        let s = baseScale(image: image, frame: frame) * zoom
        guard s > 0, image.width > 0, image.height > 0 else { return CGRect(x: 0, y: 0, width: 1, height: 1) }
        let visW = frame.width / s
        let visH = frame.height / s
        let cx = image.width / 2 - offset.width / s
        let cy = image.height / 2 - offset.height / s
        var r = CGRect(x: (cx - visW / 2) / image.width,
                       y: (cy - visH / 2) / image.height,
                       width: visW / image.width,
                       height: visH / image.height)
        // Invisible internal correction — the region never leaves the unit rect
        r.origin.x = Swift.min(Swift.max(r.origin.x, 0), Swift.max(0, 1 - r.width))
        r.origin.y = Swift.min(Swift.max(r.origin.y, 0), Swift.max(0, 1 - r.height))
        r.size.width = Swift.min(r.width, 1)
        r.size.height = Swift.min(r.height, 1)
        return r
    }

    /// Persistent region → viewport for ANY frame size (the inverse
    /// that makes the configuration viewport-independent).
    static func viewport(region: CGRect, image: CGSize, frame: CGSize) -> (zoom: CGFloat, offset: CGSize) {
        let base = baseScale(image: image, frame: frame)
        guard base > 0, region.width > 0 else { return (1, .zero) }
        let s = frame.width / (region.width * image.width)
        let zoom = Swift.max(minZoom, s / base)
        let sEff = base * zoom
        let cx = region.midX * image.width
        let cy = region.midY * image.height
        let offset = CGSize(width:  (image.width / 2 - cx) * sEff,
                            height: (image.height / 2 - cy) * sEff)
        return (zoom, clampOffset(offset, image: image, frame: frame, zoom: zoom))
    }

    /// Region → integral source-pixel rect. Never exceeds source bounds,
    /// never empty for a valid region.
    static func pixelRect(region: CGRect, sourcePixels: CGSize) -> CGRect {
        var r = CGRect(x: region.origin.x * sourcePixels.width,
                       y: region.origin.y * sourcePixels.height,
                       width: region.width * sourcePixels.width,
                       height: region.height * sourcePixels.height).integral
        r.size.width  = Swift.max(1, Swift.min(r.width,  sourcePixels.width))
        r.size.height = Swift.max(1, Swift.min(r.height, sourcePixels.height))
        r.origin.x = Swift.min(Swift.max(r.origin.x, 0), sourcePixels.width  - r.width)
        r.origin.y = Swift.min(Swift.max(r.origin.y, 0), sourcePixels.height - r.height)
        return r
    }
}

// MARK: - DEBUG self-checks (until an XCTest target exists in Xcode)

#if DEBUG
extension CropGeometry {
    /// Asserts the core invariants across representative fixtures.
    /// Mirrored by PictureArtTests/CropGeometryTests.swift.
    @discardableResult
    static func runSelfChecks() -> Bool {
        let fixtures: [CGSize] = [
            CGSize(width: 3024, height: 4032),   // portrait photo
            CGSize(width: 4032, height: 3024),   // landscape photo
            CGSize(width: 2000, height: 2000),   // square
            CGSize(width: 12000, height: 3000),  // panorama
            CGSize(width: 1000, height: 8000),   // very tall
            CGSize(width: 320, height: 480),     // low resolution
        ]
        let frames: [CGSize] = [
            CGSize(width: 300, height: 424),     // A-portrait on small phone
            CGSize(width: 380, height: 269),     // A-landscape on large phone
            CGSize(width: 320, height: 320),     // square
        ]
        let eps: CGFloat = 0.001

        for px in fixtures {
            let pts = CGSize(width: px.width / 2, height: px.height / 2) // scale-2 image
            for frame in frames {
                // 1. Default full() region stays inside the unit rect and matches aspect
                for aspect in [CropAspect.aSeriesPortrait, .aSeriesLandscape, .square, .original] {
                    let cfg = CropConfiguration.full(for: px, aspect: aspect)
                    assert(cfg.region.minX >= -eps && cfg.region.minY >= -eps
                           && cfg.region.maxX <= 1 + eps && cfg.region.maxY <= 1 + eps, "full() outside unit")
                    assert(cfg.region.width > 0 && cfg.region.height > 0, "full() empty")
                    let got = (cfg.region.width * px.width) / (cfg.region.height * px.height)
                    assert(abs(got - aspect.ratio(for: px)) < 0.01, "full() aspect drift")
                }

                // 2. Round-trip viewport → region → viewport
                let maxZ = maxZoom(imagePoints: pts, pixelScale: 2, frame: frame)
                for z in [CGFloat(1), (1 + maxZ) / 2, maxZ] {
                    let rawOffset = CGSize(width: 37, height: -22)
                    let off = clampOffset(rawOffset, image: pts, frame: frame, zoom: z)
                    let reg = region(zoom: z, offset: off, image: pts, frame: frame)
                    let back = viewport(region: reg, image: pts, frame: frame)
                    assert(abs(back.zoom - z) < 0.02 * z, "zoom round-trip drift")
                    assert(abs(back.offset.width - off.width) < 1 && abs(back.offset.height - off.height) < 1,
                           "offset round-trip drift")
                }

                // 3. Clamped offset never exposes emptiness
                let s = baseScale(image: pts, frame: frame) * 2
                let extreme = clampOffset(CGSize(width: 99999, height: -99999), image: pts, frame: frame, zoom: 2)
                assert(abs(extreme.width)  <= (pts.width  * s - frame.width)  / 2 + eps, "offset X unclamped")
                assert(abs(extreme.height) <= (pts.height * s - frame.height) / 2 + eps, "offset Y unclamped")

                // 4. pixelRect inside bounds, integral, non-empty
                let reg = region(zoom: 1.7, offset: .zero, image: pts, frame: frame)
                let pr = pixelRect(region: reg, sourcePixels: px)
                assert(pr.minX >= 0 && pr.minY >= 0 && pr.maxX <= px.width + eps && pr.maxY <= px.height + eps,
                       "pixelRect outside source")
                assert(pr.width >= 1 && pr.height >= 1, "pixelRect empty")
                assert(pr == pr.integral, "pixelRect not integral")
            }
        }

        // 5. Custom aspect (Paper-stage hook) accepted end to end
        let custom = CropConfiguration.full(for: CGSize(width: 3000, height: 4000), aspect: .custom(0.75))
        assert(abs((custom.region.width * 3000) / (custom.region.height * 4000) - 0.75) < 0.01, "custom aspect")

        return true
    }
}
#endif
