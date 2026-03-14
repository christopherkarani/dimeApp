//
//  ShaderEffects.swift
//  dime
//
//  Metal shader view modifiers — iOS 17+ with transparent fallback.
//

import SwiftUI

// MARK: - Shader 1: Key Ripple

@available(iOS 17, *)
struct ShaderKeyRippleModifier: ViewModifier {
    let touchPoint: CGPoint
    let trigger: Int
    let buttonSize: CGSize

    @State private var rippleStart: Date?

    func body(content: Content) -> some View {
        TimelineView(.animation(paused: rippleStart == nil)) { timeline in
            let elapsed = rippleStart.map { timeline.date.timeIntervalSince($0) } ?? 0
            content.visualEffect { content, _ in
                content.colorEffect(
                    ShaderLibrary.keyRipple(
                        .float2(buttonSize),
                        .float2(touchPoint),
                        .float(elapsed),
                        .float(0.25) // 250ms duration
                    ),
                    isEnabled: rippleStart != nil && elapsed < 0.3
                )
            }
        }
        .onChange(of: trigger) { _ in
            rippleStart = .now
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                rippleStart = nil
            }
        }
    }
}

extension View {
    func shaderKeyRipple(at point: CGPoint, trigger: Int, size: CGSize) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderKeyRippleModifier(touchPoint: point, trigger: trigger, buttonSize: size))
        } else {
            self
        }
    }
}

// MARK: - Shader 2: Bar Shimmer (Vertical)

@available(iOS 17, *)
struct ShaderBarShimmerModifier: ViewModifier {
    let progress: CGFloat

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.colorEffect(
                ShaderLibrary.barShimmer(
                    .float2(proxy.size),
                    .float(progress)
                ),
                isEnabled: progress < 1.0
            )
        }
    }
}

extension View {
    func shaderBarShimmer(progress: CGFloat) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderBarShimmerModifier(progress: progress))
        } else {
            self
        }
    }
}

// MARK: - Shader 2b: Bar Shimmer (Horizontal)

@available(iOS 17, *)
struct ShaderBarShimmerHModifier: ViewModifier {
    let progress: CGFloat

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.colorEffect(
                ShaderLibrary.barShimmerH(
                    .float2(proxy.size),
                    .float(progress)
                ),
                isEnabled: progress < 1.0
            )
        }
    }
}

extension View {
    func shaderBarShimmerH(progress: CGFloat) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderBarShimmerHModifier(progress: progress))
        } else {
            self
        }
    }
}

// MARK: - Shader 3: Arc Glow

@available(iOS 17, *)
struct ShaderArcGlowModifier: ViewModifier {
    let percent: Double

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.colorEffect(
                ShaderLibrary.arcGlow(
                    .float2(proxy.size),
                    .float(percent)
                ),
                isEnabled: percent > 0
            )
        }
    }
}

extension View {
    func shaderArcGlow(percent: Double) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderArcGlowModifier(percent: percent))
        } else {
            self
        }
    }
}

// MARK: - Shader 4: Area Fill

@available(iOS 17, *)
struct ShaderAreaFillModifier: ViewModifier {
    let progress: CGFloat
    let time: Double

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.colorEffect(
                ShaderLibrary.areaFill(
                    .float2(proxy.size),
                    .float(progress),
                    .float(time)
                ),
                isEnabled: true
            )
        }
    }
}

extension View {
    func shaderAreaFill(progress: CGFloat, time: Double) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderAreaFillModifier(progress: progress, time: time))
        } else {
            self
        }
    }
}

// MARK: - Shader 5a: Swipe Warp

@available(iOS 17, *)
struct ShaderSwipeWarpModifier: ViewModifier {
    let offset: CGFloat

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.distortionEffect(
                ShaderLibrary.swipeWarp(
                    .float2(proxy.size),
                    .float(offset)
                ),
                maxSampleOffset: CGSize(width: 60, height: 0),
                isEnabled: abs(offset) > 1
            )
        }
    }
}

extension View {
    func shaderSwipeWarp(offset: CGFloat) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderSwipeWarpModifier(offset: offset))
        } else {
            self
        }
    }
}

// MARK: - Shader 5b: Delete Vignette

@available(iOS 17, *)
struct ShaderDeleteVignetteModifier: ViewModifier {
    let isConfirming: Bool

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.colorEffect(
                ShaderLibrary.deleteVignette(
                    .float2(proxy.size),
                    .float(isConfirming ? 1.0 : 0.0)
                ),
                isEnabled: isConfirming
            )
        }
    }
}

extension View {
    func shaderDeleteVignette(isConfirming: Bool) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderDeleteVignetteModifier(isConfirming: isConfirming))
        } else {
            self
        }
    }
}

// MARK: - Shader 6: Ink Reveal

@available(iOS 17, *)
struct ShaderInkRevealModifier<T: Equatable>: ViewModifier {
    let trigger: T
    @State private var revealProgress: CGFloat = 0
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.visualEffect { content, proxy in
            content.colorEffect(
                ShaderLibrary.inkReveal(
                    .float2(proxy.size),
                    .float(revealProgress)
                ),
                isEnabled: revealProgress < 1.0
            )
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                withAnimation(.easeOut(duration: 0.4)) {
                    revealProgress = 1.0
                }
            }
        }
        .onChange(of: trigger) { _ in
            revealProgress = 0
            withAnimation(.easeOut(duration: 0.4)) {
                revealProgress = 1.0
            }
        }
    }
}

extension View {
    func shaderInkReveal<T: Equatable>(trigger: T) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderInkRevealModifier(trigger: trigger))
        } else {
            self
        }
    }
}

// MARK: - Shader 7: Grain Overlay

@available(iOS 17, *)
struct ShaderGrainOverlayModifier: ViewModifier {
    let intensity: Double

    func body(content: Content) -> some View {
        content.colorEffect(
            ShaderLibrary.grainOverlay(.float(intensity)),
            isEnabled: true
        )
    }
}

extension View {
    func shaderGrainOverlay(intensity: Double = 0.015) -> some View {
        if #available(iOS 17, *) {
            self.modifier(ShaderGrainOverlayModifier(intensity: intensity))
        } else {
            self
        }
    }
}
