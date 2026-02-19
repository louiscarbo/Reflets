//
//  Outline.metal
//  Reflets
//
//  Created by Louis Carbo Estaque on 17/02/2026.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 outline(
    float2 position,
    SwiftUI::Layer layer,
    float width
) {
    // Get the original color at this position
    half4 color = layer.sample(position);
    
    // Sample surrounding pixels at multiple radii for smoother detection
    float maxAlpha = 0.0;
    int samples = 32; // More samples for smoother outline
    int rings = 2; // Sample at multiple distances
    
    for (int r = 1; r <= rings; r++) {
        float radius = width * (float(r) / float(rings));
        for (int i = 0; i < samples; i++) {
            float angle = (float(i) / float(samples)) * 2.0 * M_PI_F;
            float2 offset = float2(cos(angle), sin(angle)) * radius;
            half4 sample = layer.sample(position + offset);
            maxAlpha = max(maxAlpha, float(sample.a));
        }
    }
    
    // Smooth blending: if nearby pixels have higher alpha, blend towards white outline
    float alphaDiff = maxAlpha - color.a;
    if (alphaDiff > 0.2) {
        // Smooth interpolation for the outline
        float outlineStrength = smoothstep(0.2, 0.6, alphaDiff);
        return mix(color, half4(1.0, 1.0, 1.0, 1.0), half(outlineStrength));
    }
    
    // Otherwise return original color
    return color;
}

