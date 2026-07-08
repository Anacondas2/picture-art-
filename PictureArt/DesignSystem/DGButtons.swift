import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Button components
//  Wrapper views with built-in hit targets, haptics, loading and
//  disabled behavior. GlassCTAStyle / GlassSecondaryStyle (tokens
//  file) remain the underlying press styles.
// ═══════════════════════════════════════════════════════════════

/// Primary CTA — white pill, ink label, 54pt. One per screen.
struct DGPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            ZStack {
                // Label keeps its width while loading so the pill doesn't jump
                HStack(spacing: DG.Space.s) {
                    if let icon = systemImage {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title).dgButtonLabel()
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView().tint(.ink)
                }
            }
            .foregroundColor(.ink)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
        }
        .buttonStyle(GlassCTAStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.4 : 1)
    }
}

/// Secondary — frosted capsule, 44pt.
struct DGSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: DG.Space.s - 2) {
                if let icon = systemImage {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title).dgButtonLabel()
            }
            .foregroundColor(.ink)
            .padding(.horizontal, DG.Space.l - 4)
            .frame(minHeight: DG.touchTarget)
        }
        .buttonStyle(GlassSecondaryStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1)
    }
}

/// Ghost — text only, brand accent, full 44pt hit area. Tertiary actions.
struct DGGhostButton: View {
    let title: String
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Button(role: role) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(role == .destructive ? .destructive : .brand)
                .frame(minHeight: DG.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Icon button — 44pt frosted circle. Always pass an accessibility label.
struct DGIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var tint: Color = .brand
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(tint)
                .frame(width: DG.touchTarget, height: DG.touchTarget)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.24))
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(GlassSecondaryStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

/// Destructive — frosted capsule with red label + icon.
/// Keep spatially separated from the primary action.
struct DGDestructiveButton: View {
    let title: String
    var systemImage: String = "trash"
    let action: () -> Void

    var body: some View {
        Button {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            action()
        } label: {
            HStack(spacing: DG.Space.s - 2) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                Text(title).dgButtonLabel()
            }
            .foregroundColor(.destructive)
            .padding(.horizontal, DG.Space.l - 4)
            .frame(minHeight: DG.touchTarget)
        }
        .buttonStyle(GlassSecondaryStyle())
    }
}
