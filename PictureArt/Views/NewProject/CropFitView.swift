import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Crop & Framing (Stage 7B)
//  UI layer only: gestures, chips, states. All math delegates to
//  CropGeometry; the persistent result is a normalized
//  CropConfiguration that survives re-entry and any screen size.
//  The workspace displays a bounded preview; the output bitmap is
//  rendered from the full-resolution source at Continue.
// ═══════════════════════════════════════════════════════════════

struct CropFitView: View {
    let source: UIImage                              // full-res, orientation baked
    @Binding var configuration: CropConfiguration?   // survives the sheet session
    var onContinue: (UIImage) -> Void

    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("cropGestureHintShown") private var hintShown = false

    // Committed viewport (transient UI state; the region is the truth)
    @State private var aspect: CropAspect = .aSeriesPortrait
    @State private var zoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero
    @State private var restored = false
    @State private var display: UIImage?

    private var isRU: Bool { lm.currentLanguage == "ru" }
    private var imagePoints: CGSize { source.size }
    private var sourcePixels: CGSize {
        CGSize(width: source.size.width * source.scale,
               height: source.size.height * source.scale)
    }

    private func aspectLabel(_ a: CropAspect) -> String {
        switch a {
        case .aSeriesPortrait:  return isRU ? "Вертикально" : "Portrait"
        case .aSeriesLandscape: return isRU ? "Горизонтально" : "Landscape"
        case .square:           return isRU ? "Квадрат" : "Square"
        case .original:         return isRU ? "Оригинал" : "Original"
        case .custom:           return isRU ? "Свой размер" : "Custom"
        }
    }

    private func aspectIcon(_ a: CropAspect) -> String {
        switch a {
        case .aSeriesPortrait:  return "rectangle.portrait"
        case .aSeriesLandscape: return "rectangle"
        case .square:           return "square"
        case .original:         return "photo"
        case .custom:           return "aspectratio"
        }
    }

    /// Stage-7 preset row. `.custom` arrives later from the Paper stage.
    private let presets: [CropAspect] = [.aSeriesPortrait, .aSeriesLandscape, .square, .original]

    var body: some View {
        GeometryReader { geo in
            let frame = frameSize(for: aspect, in: geo.size)

            VStack(spacing: 0) {
                Text(isRU ? "Выберите кадр под лист" : "Frame it for your paper")
                    .dgSectionTitle()
                    .padding(.top, DG.Space.m)

                Spacer(minLength: DG.Space.s)

                workspace(frame: frame, available: geo.size)

                Spacer(minLength: DG.Space.s)

                // Aspect presets
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DG.Space.s + 2) {
                        ForEach(presets, id: \.self) { a in
                            DGChip(icon: aspectIcon(a), label: aspectLabel(a), isSelected: aspect == a) {
                                switchAspect(to: a, available: geo.size)
                            }
                        }
                    }
                    .padding(.horizontal, DG.Space.margin)
                }

                // One-time gesture hint / adjustment row
                HStack(spacing: DG.Space.m) {
                    zoomButton(systemImage: "minus.magnifyingglass",
                               label: isRU ? "Отдалить" : "Zoom out",
                               enabled: aspect != .original && zoom > CropGeometry.minZoom + 0.01) {
                        stepZoom(by: 1 / 1.25, frame: frame)
                    }
                    Group {
                        if !hintShown && aspect != .original {
                            Text(isRU ? "Двигайте и масштабируйте жестами" : "Drag and pinch to frame")
                                .dgCaption()
                        } else {
                            DGGhostButton(title: isRU ? "Сбросить" : "Reset") {
                                resetFraming(available: geo.size)
                            }
                            .opacity(isAdjusted && aspect != .original ? 1 : 0)
                            .disabled(!isAdjusted || aspect == .original)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    zoomButton(systemImage: "plus.magnifyingglass",
                               label: isRU ? "Приблизить" : "Zoom in",
                               enabled: aspect != .original && zoom < maxZoom(frame: frame) - 0.01) {
                        stepZoom(by: 1.25, frame: frame)
                    }
                }
                .padding(.horizontal, DG.Space.margin)
                .padding(.top, DG.Space.xs)

                DGPrimaryButton(title: isRU ? "Продолжить" : "Continue") {
                    onContinue(renderOutput())
                }
                .padding(.horizontal, DG.Space.margin)
                .padding(.bottom, DG.Space.m)
            }
            .onAppear { restoreIfNeeded(available: geo.size) }
        }
        .task {
            // Bounded preview for the workspace; source stays untouched
            if display == nil {
                let src = source
                display = await Task.detached(priority: .userInitiated) {
                    max(src.size.width, src.size.height) > 1600
                        ? src.resizedToFit(maxDimension: 1600)
                        : src
                }.value
            }
        }
    }

    private var isAdjusted: Bool { zoom != 1 || offset != .zero }

    // MARK: - Workspace

    @ViewBuilder
    private func workspace(frame: CGSize, available: CGSize) -> some View {
        let liveZoom = zoom * gestureZoom
        let liveOffset = CropGeometry.clampOffset(
            CGSize(width: offset.width + gestureOffset.width,
                   height: offset.height + gestureOffset.height),
            image: imagePoints, frame: frame, zoom: liveZoom
        )

        ZStack {
            if aspect == .original {
                previewImage
                    .aspectRatio(contentMode: .fit)
                    .frame(width: frame.width, height: frame.height)
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                            .strokeBorder(Color.glassEdge, lineWidth: 1)
                    )
            } else {
                // Dimmed exterior: same transform, ghosted, unclipped
                transformedImage(frame: frame, zoom: liveZoom, offset: liveOffset)
                    .opacity(0.35)

                // The framed crop — full strength, clipped
                transformedImage(frame: frame, zoom: liveZoom, offset: liveOffset)
                    .frame(width: frame.width, height: frame.height)
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))

                thirdsGuide(frame: frame)

                RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
                    .frame(width: frame.width, height: frame.height)
            }
        }
        .frame(width: frame.width, height: frame.height)
        .shadow(color: Color.glassShadow.opacity(0.22), radius: 20, x: 0, y: 10)
        .contentShape(Rectangle())
        .gesture(aspect == .original ? nil : panAndZoom(frame: frame))
        .simultaneousGesture(aspect == .original ? nil : doubleTap(frame: frame))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRU
            ? "Область кадрирования, выбрано: \(aspectLabel(aspect))"
            : "Crop area, selected ratio: \(aspectLabel(aspect))")
        .accessibilityHint(isRU
            ? "Жесты или кнопки масштаба меняют кадр. Пропорция Оригинал пропускает кадрирование."
            : "Use gestures or the zoom buttons to adjust. The Original preset skips cropping.")
        .accessibilityAdjustableAction { direction in
            let frame = frame
            switch direction {
            case .increment: stepZoom(by: 1.25, frame: frame)
            case .decrement: stepZoom(by: 1 / 1.25, frame: frame)
            @unknown default: break
            }
        }
    }

    @ViewBuilder
    private var previewImage: some View {
        if let display {
            Image(uiImage: display).resizable()
        } else {
            Color.white.opacity(0.30)
                .overlay(ProgressView().tint(.brand))
        }
    }

    @ViewBuilder
    private func transformedImage(frame: CGSize, zoom: CGFloat, offset: CGSize) -> some View {
        previewImage
            .aspectRatio(contentMode: .fill)
            .frame(width: frame.width, height: frame.height)
            .scaleEffect(zoom)
            .offset(offset)
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private func thirdsGuide(frame: CGSize) -> some View {
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

    private func zoomButton(systemImage: String, label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        DGIconButton(systemImage: systemImage, accessibilityLabel: label,
                     tint: enabled ? .brand : .inkTertiary) {
            if enabled { action() }
        }
        .disabled(!enabled)
    }

    // MARK: - Layout

    private func frameSize(for aspect: CropAspect, in available: CGSize) -> CGSize {
        let maxW = available.width - DG.Space.margin * 2
        let maxH = available.height * 0.52
        let ratio = aspect.ratio(for: imagePoints)
        var w = maxW
        var h = w / ratio
        if h > maxH { h = maxH; w = h * ratio }
        return CGSize(width: w, height: h)
    }

    private func maxZoom(frame: CGSize) -> CGFloat {
        CropGeometry.maxZoom(imagePoints: imagePoints, pixelScale: source.scale, frame: frame)
    }

    // MARK: - State transitions

    private func restoreIfNeeded(available: CGSize) {
        guard !restored else { return }
        restored = true
        if let cfg = configuration, cfg.sourceSize == sourcePixels {
            aspect = cfg.aspect
            let frame = frameSize(for: cfg.aspect, in: available)
            let vp = CropGeometry.viewport(region: cfg.region, image: imagePoints, frame: frame)
            zoom = vp.zoom
            offset = vp.offset
        } else {
            commit(frame: frameSize(for: aspect, in: available))
        }
    }

    private func switchAspect(to newAspect: CropAspect, available: CGSize) {
        guard newAspect != aspect else { return }
        // Carry the focal center into the new aspect's max-coverage region
        let oldFrame = frameSize(for: aspect, in: available)
        let oldRegion = CropGeometry.region(zoom: zoom, offset: offset, image: imagePoints, frame: oldFrame)
        let focus = CGPoint(x: oldRegion.midX, y: oldRegion.midY)
        let cfg = CropConfiguration.full(for: sourcePixels, aspect: newAspect, focus: focus)

        let newFrame = frameSize(for: newAspect, in: available)
        let vp = CropGeometry.viewport(region: cfg.region, image: imagePoints, frame: newFrame)

        withAnimation(reduceMotion ? nil : DGMotion.spring) {
            aspect = newAspect
            zoom = vp.zoom
            offset = vp.offset
        }
        configuration = cfg
        UIAccessibility.post(notification: .announcement, argument: aspectLabel(newAspect))
    }

    private func stepZoom(by factor: CGFloat, frame: CGSize) {
        let newZoom = min(maxZoom(frame: frame), max(CropGeometry.minZoom, zoom * factor))
        let ratio = newZoom / max(zoom, 0.0001)
        let newOffset = CropGeometry.clampOffset(
            CGSize(width: offset.width * ratio, height: offset.height * ratio),
            image: imagePoints, frame: frame, zoom: newZoom
        )
        withAnimation(reduceMotion ? nil : DGMotion.press) {
            zoom = newZoom
            offset = newOffset
        }
        commit(frame: frame)
        UIAccessibility.post(notification: .announcement,
                             argument: "\(Int(newZoom * 100))%")
    }

    private func resetFraming(available: CGSize) {
        let frame = frameSize(for: aspect, in: available)
        withAnimation(reduceMotion ? nil : DGMotion.spring) {
            zoom = 1
            offset = .zero
        }
        commit(frame: frame)
        UIAccessibility.post(notification: .announcement,
                             argument: isRU ? "Кадр сброшен" : "Framing reset")
    }

    /// Commit the current viewport as the persistent normalized region.
    private func commit(frame: CGSize) {
        let region = aspect == .original
            ? CGRect(x: 0, y: 0, width: 1, height: 1)
            : CropGeometry.region(zoom: zoom, offset: offset, image: imagePoints, frame: frame)
        configuration = CropConfiguration(region: region, aspect: aspect, sourceSize: sourcePixels)
        if !hintShown && isAdjusted { hintShown = true }
    }

    // MARK: - Gestures

    private func panAndZoom(frame: CGSize) -> some Gesture {
        let drag = DragGesture()
            .updating($gestureOffset) { value, state, _ in state = value.translation }
            .onEnded { value in
                offset = CropGeometry.clampOffset(
                    CGSize(width: offset.width + value.translation.width,
                           height: offset.height + value.translation.height),
                    image: imagePoints, frame: frame, zoom: zoom
                )
                commit(frame: frame)
            }
        let pinch = MagnificationGesture()
            .updating($gestureZoom) { value, state, _ in state = value }
            .onEnded { value in
                zoom = min(maxZoom(frame: frame), max(CropGeometry.minZoom, zoom * value))
                offset = CropGeometry.clampOffset(offset, image: imagePoints, frame: frame, zoom: zoom)
                commit(frame: frame)
            }
        return drag.simultaneously(with: pinch)
    }

    private func doubleTap(frame: CGSize) -> some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                let target: CGFloat = zoom > 1.01 ? 1 : min(2, maxZoom(frame: frame))
                // Keep the tapped point stationary: o' = p − (p − o)·(z'/z)
                let p = CGSize(width: value.location.x - frame.width / 2,
                               height: value.location.y - frame.height / 2)
                let k = target / max(zoom, 0.0001)
                let raw = CGSize(width: p.width - (p.width - offset.width) * k,
                                 height: p.height - (p.height - offset.height) * k)
                withAnimation(reduceMotion ? nil : DGMotion.spring) {
                    zoom = target
                    offset = CropGeometry.clampOffset(raw, image: imagePoints, frame: frame, zoom: target)
                }
                commit(frame: frame)
            }
    }

    // MARK: - Output (full-resolution, from the persistent region)

    private func renderOutput() -> UIImage {
        guard let cfg = configuration, cfg.aspect != .original else { return source }
        let px = CropGeometry.pixelRect(region: cfg.region, sourcePixels: sourcePixels)
        guard let cg = source.cgImage?.cropping(to: px) else { return source }
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
            configuration: .constant(nil),
            onContinue: { _ in }
        )
        .environmentObject(LocalizationManager.shared)
    }
}

#Preview("Geometry self-checks") {
    // Runs the assertion suite; a visible checkmark means it passed.
    let ok = CropGeometry.runSelfChecks()
    return ZStack {
        MistBackground()
        Label(ok ? "CropGeometry checks passed" : "FAILED",
              systemImage: ok ? "checkmark.seal" : "xmark.seal")
            .font(.system(.headline, design: .rounded))
            .foregroundColor(ok ? .progressTeal : .destructive)
    }
}
#endif
