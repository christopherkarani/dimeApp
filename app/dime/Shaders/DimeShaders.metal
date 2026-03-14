#include <metal_stdlib>
using namespace metal;

// MARK: - Noise Helper

static half hash(float2 p) {
    return half(fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453));
}

// MARK: - Shader 1: NumberPad Key Ripple (colorEffect)

[[ stitchable ]] half4 keyRipple(
    float2 position, half4 color,
    float2 size, float2 touchPoint, float time, float duration
) {
    if (color.a < 0.01h) return color;
    if (time >= duration || time <= 0.0) return color;

    half progress = half(time / duration);
    half2 uv = half2(position / size);
    half2 center = half2(touchPoint / size);
    half dist = length(uv - center);

    half ringRadius = progress * 0.7h;
    half ringWidth = 0.08h;
    half ring = smoothstep(ringRadius - ringWidth, ringRadius, dist)
              * smoothstep(ringRadius + ringWidth, ringRadius, dist);

    half fade = 1.0h - progress;
    half boost = ring * fade * 0.08h;

    return half4(color.rgb + boost, color.a);
}

// MARK: - Shader 2: Bar Chart Shimmer — vertical (colorEffect)

[[ stitchable ]] half4 barShimmer(
    float2 position, half4 color,
    float2 size, float progress
) {
    if (color.a < 0.01h) return color;
    if (progress >= 1.0) return color;

    half uv_y = half(position.y / size.y);
    half bandCenter = 1.0h - half(progress);
    half halfWidth = 0.15h;
    half band = smoothstep(bandCenter - halfWidth, bandCenter, uv_y)
              * smoothstep(bandCenter + halfWidth, bandCenter, uv_y);

    half boost = band * 0.12h;
    return half4(color.rgb + boost * color.a, color.a);
}

// MARK: - Shader 2b: Bar Chart Shimmer — horizontal (colorEffect)

[[ stitchable ]] half4 barShimmerH(
    float2 position, half4 color,
    float2 size, float progress
) {
    if (color.a < 0.01h) return color;
    if (progress >= 1.0) return color;

    half uv_x = half(position.x / size.x);
    half bandCenter = half(progress);
    half halfWidth = 0.15h;
    half band = smoothstep(bandCenter - halfWidth, bandCenter, uv_x)
              * smoothstep(bandCenter + halfWidth, bandCenter, uv_x);

    half boost = band * 0.06h; // reduced for colored bars
    return half4(color.rgb + boost * color.a, color.a);
}

// MARK: - Shader 3: Budget Donut Arc Glow (colorEffect)

[[ stitchable ]] half4 arcGlow(
    float2 position, half4 color,
    float2 size, float percent
) {
    if (color.a < 0.01h) return color;
    if (percent <= 0.0) return color;

    // Arc center is bottom-center of semicircle bounding box
    float2 center = float2(size.x / 2.0, size.y);
    // Y-axis flip: Metal Y points down, atan2 expects math convention
    float angle = atan2(-(position.y - center.y), position.x - center.x);
    // Normalize angle to [0, PI] range (semicircle)
    if (angle < 0.0) angle += 2.0 * M_PI_F;

    float leadingEdge = M_PI_F + M_PI_F * percent;
    float proximity = abs(angle - leadingEdge);
    // Wrap around
    proximity = min(proximity, 2.0 * M_PI_F - proximity);

    half glow = half(exp(-proximity * 8.0));
    half boost = glow * 0.15h;

    return half4(color.rgb + boost * color.a, color.a);
}

// MARK: - Shader 4: Line Graph Area Fill (colorEffect)

[[ stitchable ]] half4 areaFill(
    float2 position, half4 color,
    float2 size, float progress, float breathe
) {
    if (color.a < 0.01h) return color;

    half uv_x = half(position.x / size.x);
    half uv_y = half(position.y / size.y);

    // Clip horizontally based on animation progress
    if (uv_x > half(progress)) return half4(0.0h);

    // Vertical gradient: opaque at top, transparent at bottom
    half verticalFade = 1.0h - uv_y;

    // Breathing: subtle oscillation
    half breatheOffset = half(sin(breathe * 1.5707963) * 0.02);

    half alpha = (0.15h + breatheOffset) * verticalFade;
    return half4(color.rgb * alpha, alpha) * color.a;
}

// MARK: - Shader 5a: Transaction Row Swipe Warp (distortionEffect)

[[ stitchable ]] float2 swipeWarp(
    float2 position, float2 size, float offset
) {
    if (abs(offset) < 1.0) return position;

    float t = abs(offset) / size.x;
    float normalizedX = position.x / size.x;

    // Compress pixels near trailing edge when swiping left
    float warp = t * 0.15 * normalizedX;
    float2 result = position;
    result.x = position.x * (1.0 + warp);

    return result;
}

// MARK: - Shader 5b: Delete Vignette (colorEffect)

[[ stitchable ]] half4 deleteVignette(
    float2 position, half4 color,
    float2 size, float deleteProgress
) {
    if (color.a < 0.01h) return color;
    if (deleteProgress <= 0.0) return color;

    half edgeProximity = smoothstep(0.3h, 1.0h, half(position.x / size.x));
    half4 redTint = half4(0.86h, 0.15h, 0.15h, 1.0h) * color.a; // vRed-ish
    half mixAmount = half(deleteProgress) * edgeProximity * 0.3h;

    return mix(color, redTint, mixAmount);
}

// MARK: - Shader 6: Insights Amount Ink Reveal (colorEffect)

[[ stitchable ]] half4 inkReveal(
    float2 position, half4 color,
    float2 size, float progress
) {
    if (progress >= 1.0) return color;

    half noise = hash(float2(position.x * 0.1, position.y * 0.1));
    half threshold = half(progress) * 1.3h + noise * 0.15h;
    half edgeSoftness = smoothstep(threshold - 0.05h, threshold, half(position.y / size.y + position.x / size.x) * 0.5h);

    // Invert: pixels below threshold are visible
    half reveal = 1.0h - smoothstep(threshold - 0.1h, threshold, 1.0h - half(progress) * 1.3h - noise * 0.15h);

    if (progress <= 0.0) return half4(0.0h);

    return color * min(reveal + half(progress), 1.0h);
}

// MARK: - Shader 7: Grain Overlay (colorEffect)

[[ stitchable ]] half4 grainOverlay(
    float2 position, half4 color,
    float grainIntensity
) {
    half grain = hash(position) - 0.5h; // center around 0
    return color + half4(grain, grain, grain, 0.0h) * half(grainIntensity);
}
