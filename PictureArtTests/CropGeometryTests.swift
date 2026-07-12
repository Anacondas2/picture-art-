import XCTest
@testable import PictureArt

// ═══════════════════════════════════════════════════════════════
//  CropGeometry unit tests.
//  NOTE: this repository has no test target yet (classic pbxproj).
//  To run: Xcode → File → New → Target → Unit Testing Bundle
//  ("PictureArtTests", host app PictureArt), then add this file to
//  the new target. Until then, the same suite runs as DEBUG
//  assertions via CropGeometry.runSelfChecks() (see the
//  "Geometry self-checks" preview in CropFitView.swift).
// ═══════════════════════════════════════════════════════════════

final class CropGeometryTests: XCTestCase {

    private let fixturesPx: [CGSize] = [
        CGSize(width: 3024, height: 4032),   // portrait
        CGSize(width: 4032, height: 3024),   // landscape
        CGSize(width: 2000, height: 2000),   // square
        CGSize(width: 12000, height: 3000),  // panorama
        CGSize(width: 1000, height: 8000),   // very tall
        CGSize(width: 320, height: 480),     // low resolution
    ]
    private let frames: [CGSize] = [
        CGSize(width: 300, height: 424),
        CGSize(width: 380, height: 269),
        CGSize(width: 320, height: 320),
    ]

    func testFullRegionMatchesAspectAndStaysInUnitRect() {
        for px in fixturesPx {
            for aspect in [CropAspect.aSeriesPortrait, .aSeriesLandscape, .square, .original, .custom(0.75)] {
                let cfg = CropConfiguration.full(for: px, aspect: aspect)
                XCTAssertGreaterThan(cfg.region.width, 0)
                XCTAssertGreaterThan(cfg.region.height, 0)
                XCTAssertGreaterThanOrEqual(cfg.region.minX, -0.001)
                XCTAssertGreaterThanOrEqual(cfg.region.minY, -0.001)
                XCTAssertLessThanOrEqual(cfg.region.maxX, 1.001)
                XCTAssertLessThanOrEqual(cfg.region.maxY, 1.001)
                let got = (cfg.region.width * px.width) / (cfg.region.height * px.height)
                XCTAssertEqual(got, aspect.ratio(for: px), accuracy: 0.01)
            }
        }
    }

    func testViewportRegionRoundTrip() {
        for px in fixturesPx {
            let pts = CGSize(width: px.width / 2, height: px.height / 2)
            for frame in frames {
                let maxZ = CropGeometry.maxZoom(imagePoints: pts, pixelScale: 2, frame: frame)
                for z in [CGFloat(1), (1 + maxZ) / 2, maxZ] {
                    let off = CropGeometry.clampOffset(CGSize(width: 37, height: -22),
                                                       image: pts, frame: frame, zoom: z)
                    let region = CropGeometry.region(zoom: z, offset: off, image: pts, frame: frame)
                    let back = CropGeometry.viewport(region: region, image: pts, frame: frame)
                    XCTAssertEqual(back.zoom, z, accuracy: 0.02 * z)
                    XCTAssertEqual(back.offset.width, off.width, accuracy: 1)
                    XCTAssertEqual(back.offset.height, off.height, accuracy: 1)
                }
            }
        }
    }

    func testViewportIsScreenIndependent() {
        // The same region must restore the same visible content on any frame size
        let px = CGSize(width: 3024, height: 4032)
        let pts = CGSize(width: 1512, height: 2016)
        let small = CGSize(width: 260, height: 368)
        let large = CGSize(width: 380, height: 537)

        let off = CropGeometry.clampOffset(CGSize(width: 50, height: -40), image: pts, frame: small, zoom: 2)
        let region = CropGeometry.region(zoom: 2, offset: off, image: pts, frame: small)
        let vpLarge = CropGeometry.viewport(region: region, image: pts, frame: large)
        let regionBack = CropGeometry.region(zoom: vpLarge.zoom, offset: vpLarge.offset, image: pts, frame: large)

        XCTAssertEqual(region.midX, regionBack.midX, accuracy: 0.005)
        XCTAssertEqual(region.midY, regionBack.midY, accuracy: 0.005)
        XCTAssertEqual(region.width, regionBack.width, accuracy: 0.005)
    }

    func testOffsetClampingNeverExposesEmptiness() {
        for px in fixturesPx {
            let pts = CGSize(width: px.width / 2, height: px.height / 2)
            for frame in frames {
                let s = CropGeometry.baseScale(image: pts, frame: frame) * 2
                let clamped = CropGeometry.clampOffset(CGSize(width: 99999, height: -99999),
                                                       image: pts, frame: frame, zoom: 2)
                XCTAssertLessThanOrEqual(abs(clamped.width), (pts.width * s - frame.width) / 2 + 0.001)
                XCTAssertLessThanOrEqual(abs(clamped.height), (pts.height * s - frame.height) / 2 + 0.001)
            }
        }
    }

    func testPixelRectStaysInsideSourceAndIsIntegral() {
        for px in fixturesPx {
            let pts = CGSize(width: px.width / 2, height: px.height / 2)
            for frame in frames {
                let region = CropGeometry.region(zoom: 1.7, offset: .zero, image: pts, frame: frame)
                let pr = CropGeometry.pixelRect(region: region, sourcePixels: px)
                XCTAssertGreaterThanOrEqual(pr.minX, 0)
                XCTAssertGreaterThanOrEqual(pr.minY, 0)
                XCTAssertLessThanOrEqual(pr.maxX, px.width + 0.001)
                XCTAssertLessThanOrEqual(pr.maxY, px.height + 0.001)
                XCTAssertGreaterThanOrEqual(pr.width, 1)
                XCTAssertGreaterThanOrEqual(pr.height, 1)
                XCTAssertEqual(pr, pr.integral)
            }
        }
    }

    func testAspectSwitchCarriesFocalCenter() {
        let px = CGSize(width: 4000, height: 3000)
        let focus = CGPoint(x: 0.7, y: 0.6)
        let cfg = CropConfiguration.full(for: px, aspect: .square, focus: focus)
        // Center carried unless clamping intervened; square on 4:3 clamps only x near edges
        XCTAssertEqual(cfg.region.midY, focus.y, accuracy: 0.26) // height fully covered -> midY 0.5..; tolerant
        XCTAssertEqual(cfg.region.midX, focus.x, accuracy: 0.05)
        XCTAssertGreaterThanOrEqual(cfg.region.minX, 0)
        XCTAssertLessThanOrEqual(cfg.region.maxX, 1)
    }

    func testMaxZoomRespectsSourceResolution() {
        let frame = CGSize(width: 320, height: 452)
        // Tiny source: zoom ceiling collapses toward 1
        let tiny = CropGeometry.maxZoom(imagePoints: CGSize(width: 160, height: 240),
                                        pixelScale: 2, frame: frame)
        // Huge source: hard cap 6
        let huge = CropGeometry.maxZoom(imagePoints: CGSize(width: 6000, height: 8000),
                                        pixelScale: 2, frame: frame)
        XCTAssertLessThanOrEqual(tiny, 2.5)
        XCTAssertEqual(huge, 6, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(tiny, 1)
    }
}
