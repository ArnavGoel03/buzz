"use client";

import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { useRef, useMemo, useEffect, useState } from "react";
import * as THREE from "three";

// Fragment shader: multi-octave simplex noise warps a 3-stop gradient (yellow →
// magenta → deep blue). Shifts on scroll + cursor so the background feels alive
// without distracting from content. Runs entirely on GPU — ~0.3ms on M-chips.
const fragmentShader = /* glsl */ `
  precision highp float;
  uniform float u_time;
  uniform vec2  u_resolution;
  uniform vec2  u_mouse;
  uniform float u_scroll;
  varying vec2  v_uv;

  // Classic Ashima simplex noise (MIT)
  vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }
  float snoise(vec2 v){
    const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m*m; m = m*m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
  }

  void main() {
    vec2 uv = v_uv;
    vec2 mouse = u_mouse * 0.5;

    // Layered noise for organic motion
    float n1 = snoise(uv * 2.2 + u_time * 0.05 + mouse);
    float n2 = snoise(uv * 4.0 - u_time * 0.03 + vec2(u_scroll * 0.3, 0.0));
    float n  = n1 * 0.6 + n2 * 0.4;

    // Gradient palette — cool base with warm highlights
    vec3 c1 = vec3(0.06, 0.06, 0.10);   // deep blue-black base
    vec3 c2 = vec3(0.18, 0.08, 0.30);   // magenta bloom
    vec3 c3 = vec3(1.00, 0.84, 0.04);   // buzz yellow accent
    vec3 c4 = vec3(0.10, 0.22, 0.50);   // cool electric blue

    // Mix across the canvas based on uv + noise
    float t1 = smoothstep(-1.0, 1.0, n + uv.y * 0.4);
    float t2 = smoothstep(0.3, 1.0,  n + uv.x * 0.2 - u_scroll * 0.0005);

    vec3 col = mix(c1, c4, t1);
    col = mix(col, c2, t2 * 0.55);
    col += c3 * pow(max(0.0, n - 0.3), 2.2) * 0.35;   // rare yellow highlights

    // Vignette
    float v = 1.0 - length(uv - 0.5) * 0.9;
    col *= smoothstep(0.1, 1.0, v);

    // Film grain
    float g = fract(sin(dot(uv * u_resolution, vec2(12.9898, 78.233))) * 43758.5453);
    col += (g - 0.5) * 0.035;

    gl_FragColor = vec4(col, 1.0);
  }
`;

const vertexShader = /* glsl */ `
  varying vec2 v_uv;
  void main() {
    v_uv = uv;
    gl_Position = vec4(position, 1.0);
  }
`;

function ShaderPlane({ scroll }: { scroll: React.MutableRefObject<number> }) {
  const mesh = useRef<THREE.Mesh>(null);
  const { size } = useThree();

  const uniforms = useMemo(
    () => ({
      u_time:       { value: 0 },
      u_resolution: { value: new THREE.Vector2(size.width, size.height) },
      u_mouse:      { value: new THREE.Vector2(0, 0) },
      u_scroll:     { value: 0 },
    }),
    [size.width, size.height]
  );

  const mouseTarget = useRef(new THREE.Vector2());

  useEffect(() => {
    function onMove(e: PointerEvent) {
      mouseTarget.current.set(
        (e.clientX / window.innerWidth) * 2 - 1,
        -(e.clientY / window.innerHeight) * 2 + 1
      );
    }
    window.addEventListener("pointermove", onMove);
    return () => window.removeEventListener("pointermove", onMove);
  }, []);

  useFrame((state) => {
    uniforms.u_time.value = state.clock.elapsedTime;
    uniforms.u_mouse.value.lerp(mouseTarget.current, 0.04);
    uniforms.u_scroll.value = scroll.current;
  });

  return (
    <mesh ref={mesh}>
      <planeGeometry args={[2, 2]} />
      <shaderMaterial
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={uniforms}
        depthWrite={false}
      />
    </mesh>
  );
}

export default function ShaderBackground() {
  const scroll = useRef(0);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    function onScroll() { scroll.current = window.scrollY; }
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  if (!mounted) return null;

  return (
    <div className="fixed inset-0 -z-10 pointer-events-none">
      <Canvas
        orthographic
        camera={{ position: [0, 0, 1], zoom: 1 }}
        dpr={[1, 1.5]}
        gl={{ antialias: false, powerPreference: "low-power", alpha: false }}
      >
        <ShaderPlane scroll={scroll} />
      </Canvas>
    </div>
  );
}
