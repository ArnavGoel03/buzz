#include <metal_stdlib>
using namespace metal;

// Simplex noise-based gradient shader used as hero backgrounds on LiveNow,
// ClubsView, ProfileView, and the splash scene. Same visual language as the
// web's GLSL shader — deep blue → magenta → yellow highlights that drift on
// time and subtly warp on scroll.

inline float3 permute(float3 x) { return fmod(((x * 34.0) + 1.0) * x, 289.0); }

inline float snoise(float2 v) {
    const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);
    float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = fmod(i, 289.0);
    float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
    float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m; m = m * m;
    float3 x = 2.0 * fract(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    float3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

[[ stitchable ]] half4 buzzGradient(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / size;
    float n1 = snoise(uv * 2.2 + time * 0.05);
    float n2 = snoise(uv * 4.0 - time * 0.03);
    float n  = n1 * 0.6 + n2 * 0.4;

    half3 c1 = half3(0.06, 0.06, 0.10);
    half3 c2 = half3(0.18, 0.08, 0.30);
    half3 c3 = half3(1.00, 0.84, 0.04);
    half3 c4 = half3(0.10, 0.22, 0.50);

    float t1 = smoothstep(-1.0, 1.0, n + uv.y * 0.4);
    float t2 = smoothstep(0.3, 1.0,  n + uv.x * 0.2);

    half3 col = mix(c1, c4, half(t1));
    col = mix(col, c2, half(t2 * 0.55));
    col += c3 * half(pow(max(0.0, n - 0.3), 2.2) * 0.35);

    // Vignette
    float v = 1.0 - length(uv - 0.5) * 0.9;
    col *= half(smoothstep(0.1, 1.0, v));

    return half4(col, 1.0);
}
