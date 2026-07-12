import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Crop & Fit (Stage 7)
//  Frame the photo to the paper's proportions before configuring.
//  Aspect presets map to the real paper family (A-series sheet,
//  square canvas); "Original" keeps the photo untouched.
//  Pinch to zoom, drag to position; the crop is rendered from the
//  full-resolution source, never from the screen.
// ═══════════════════════════════════════════════════════════════

struct CropFitView: View {
    let source: UIImage                 // full-res, normalized
    var onContinue: (UIImage) -> Void   // cropped (or original) result

    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Aspect: CaseIterable {
        case portrait, landscape, square, original

        var ratio: CGFloat? {   // width / height; nil = no crop
            switch self {
            case .portrait:  return 1 / 1.414   // A-series sheet
            case .landscape: return 1.414
            case .square:    return 1
            case .original:  return nil
            }
        }

        func label(ru: Bool) -> String {
            switch self {
            case .portrait:  return ru ? "Вертикально" : "Portrait"
            case .landscape: return ru ? "Горизонтально" : "Landscape"
            case .square:    return ru ? "Квадрат" : "Square"
            case .original:  return ru ? "Оригинал" : "Original"
            }
        }

        var icon: String {
            switch self {
            case .portrait:  return "rectangle.portrait"
            case .landscape: return "rectangle"
            case .square:    return "square"
            case .original:  return "photo"
            }
        }
    }

    @State private var aspect: Aspect = .portrait
    @State private var zoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    private var isRU: Bool { lm.currentLanguage == "ru" }
    private var isAdjusted: Bool { zoom != 1 || offset != .zero }

    var body: some View {
        GeometryReader { geo in
            let frame = cropFrameSize(in: geo.size)

            VStack(spacing: 0) {
                // Instruction
                Text(isRU ? "Выберите кадр под лист" : "Frame it for your paper")
                    .dgSectionTitle()
                    .padding(.top, DG.Space.m)

                Spacer(minLength: DG.Space.s)

                // Crop stage
                cropStage(frame: frame)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: DG.Space.s)

                // Aspect presets
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DG.Space.s + 2) {
                        ForEach(Aspect.allCases, id: \.self) { a in
                            DGChip(icon: a.icon, label: a.label(ru: isRU), isSelected: aspect == a) {
                                withAnimation(reduceMotion ? nil : DGMotion.spring) {
                                    aspect = a
                                    resetAdjustments()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DG.Space.margin)
                }

                // Reset — only when the user has moved something
                DGGhostButton(title: isRU ? "Сбросить" : "Reset") {
                    withAnimation(reduceMotion ? nil : DGMotion.spring) { resetAdjustments() }
                }
                .opacity(isAdjusted && aspect != .original ? 1 : 0)
                .disabled(!isAdjusted || aspect == .original)
                .padding(.top, DG.Space.xs)

                // Continue
                DGPrimaryButton(title: isRU ? "Продолжить" : "Continue") {
                    onContinue(renderResult(frame: frame))
                }
                .padding(.horizontal, DG.Space.margin)
                .padding(.bottom, DG.Space.m)
            }
        }
    }

    // MARK: - Crop stage

    @ViewBuilder
    private func cropStage(frame: CGSize) -> some View {
        let totalZoom = zoom * gestureZoom
        let liveOffset = clampedOffset(
            CGSize(width: offset.width + gestureOffset.width,
                   height: offset.height + gestureOffset.height),
            frame: frame, zoom: totalZoom
        )

        ZStack {
            if aspect == .original {
                // No crop — show the photo as-is
                Image(uiImage: source)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: frame.width, height: frame.height)
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                            .strokeBorder(Color.glassEdge, lineWidth: 1)
                    )
            } else {
                // Image layer, panned and zoomed, clipped to the frame
                Image(uiImage: source)
                    .resizable()
                    .scaledToFill()
                    .frame(width: frame.width, height: frame.height)
                    .scaleEffect(totalZoom)
                    .offset(liveOffset)
                    .frame(width: frame.width, height: frame.height)
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))

                // Thirds guide — quiet, on brand for a grid product
                thirdsGrid(frame: frame)

                // Frame edge
                RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
                    .frame(width: frame.width, height: frame.height)
            }
        }
        .shadow(color: Color.glassShadow.opacity(0.22), radius: 20, x: 0, y: 10)
        .contentShape(Rectangle())
        .gesture(aspect == .original ? nil : panAndZoom(frame: frame))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRU
            ? "Область кадрирования. Фото можно перемещать и масштабировать жестами, либо выбрать пропорцию Оригинал, чтобы пропустить кадрирование."
            : "Crop area. Pan and pinch to adjust, or choose the Original preset to skip cropping.")
    }

    @ViewBuilder
    private func thirdsGrid(frame: CGSize) -> some View {
        Path { p in
            for i in 1...2 {
                let x = frame.width * CGFloat(i) / 3
                p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: frame.height))
                let y = frame.height * CGFloat(i) / 3
                p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: frame.width, y: y))
            }
        }
        .stroke(Color.white.opacity(0.35), lineWidth: 1)
        .frame(width: frame.width, height: frame.height)
        .allowsHitTesting(false)
    }

    // MARK: - Geometry

    private func cropFrameSize(in available: CGSize) -> CGSize {
        let maxW = available.width - DG.Space.margin * 2
        let maxH = available.height * 0.52
        let ratio = aspect.ratio ?? (source.size.width / max(source.size.height, 1))
        var w = maxW
        var h = w / ratio
        if h > maxH { h = maxH; w = h * ratio }
        return CGSize(width: w, height: h)
    }

    private func clampedOffset(_ proposed: CGSize, frame: CGSize, zoom: CGFloat) -> CGSize {
        // scaledToFill base size, then zoom
        let img = source.size
        let base = max(frame.width / img.width, frame.height / img.height)
        let dispW = img.width * base * zoom
        let dispH = img.height * base * zoom
        let maxX = max(0, (dispW - frame.width) / 2)
        let maxY = max(0, (dispH - frame.height) / 2)
        return CGSize(width: min(maxX, max(-maxX, proposed.width)),
                      height: min(maxY, max(-maxY, proposed.height)))
    }

    private func panAndZoom(frame: CGSize) -> some Gesture {
        let drag = DragGesture()
            .updating($gestureOffset) { value, state, _ in state = value.translation }
            .onEnded { value in
                offset = clampedOffset(
                    CGSize(width: offset.width + value.translation.width,
                           height: offset.height + value.translation.height),
                    frame: frame, zoom: zoom
                )
            }
        let pinch = MagnificationGesture()
            .updating($gestureZoom) { value, state, _ in state = value }
            .onEnded { value in
                zoom = min(4, max(1, zoom * value))
                offset = clampedOffset(offset, frame: frame, zoom: zoom)
            }
        return drag.simultaneously(with: pinch)
    }

    private func resetAdjustments() {
        zoom = 1
        offset = .zero
    }

    // MARK: - Render (from the full-resolution source)

    private func renderResult(frame: CGSize) -> UIImage {
        guard aspect != .original else { return source }

        let img = source.size
        let base = max(frame.width / img.width, frame.height / img.height)
        let total = base * zoom
        guard total > 0 else { return source }

        let visibleW = frame.width / total
        let visibleH = frame.height / total
        let cx = img.width / 2 - offset.width / total
        let cy = img.height / 2 - offset.height / total

        var rect = CGRect(x: cx - visibleW / 2, y: cy - visibleH / 2,
                          width: visibleW, height: visibleH)
        rect.origin.x = max(0, min(rect.origin.x, img.width - visibleW))
        rect.origin.y = max(0, min(rect.origin.y, img.height - visibleH))

        let s = source.scale
        let pixelRect = CGRect(x: rect.minX * s, y: rect.minY * s,
                               width: rect.width * s, height: rect.height * s).integral

        guard let cg = source.cgImage?.cropping(to: pixelRect) else { return source }
        return UIImage(cgImage: cg, scale: 1, orientation: .up)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Crop & Fit") {
    ZStack {
        MistBackground()
        CropFitView(
            source: UIImage(systemName: "photo")!,
            onContinue: { _ in }
        )
        .environmentObject(LocalizationManager.shared)
    }
}
#endif
