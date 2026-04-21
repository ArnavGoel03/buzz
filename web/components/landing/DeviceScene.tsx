"use client";

import { Canvas, useFrame } from "@react-three/fiber";
import { Float, Environment, ContactShadows } from "@react-three/drei";
import { useRef, useState, useEffect } from "react";
import * as THREE from "three";

// Floating 3D device mockup — WebGL-rendered iPhone chassis with a glowing event
// card "screen". Rotates on mouse position, tilts on scroll. Real-time render;
// no prebaked textures.
function Phone({
  pointer,
  scrollY,
}: {
  pointer: React.MutableRefObject<{ x: number; y: number }>;
  scrollY: React.MutableRefObject<number>;
}) {
  const group = useRef<THREE.Group>(null);

  useFrame(() => {
    if (!group.current) return;
    const tx = pointer.current.x * 0.4;
    const ty = pointer.current.y * 0.3;
    const sc = scrollY.current * 0.0015;
    group.current.rotation.y += (tx - group.current.rotation.y) * 0.08;
    group.current.rotation.x += (ty - sc - group.current.rotation.x) * 0.08;
  });

  return (
    <Float speed={1.2} rotationIntensity={0.2} floatIntensity={0.6}>
      <group ref={group}>
        {/* chassis */}
        <mesh castShadow>
          <boxGeometry args={[1.6, 3.2, 0.18]} />
          <meshPhysicalMaterial
            color="#0a0a0f"
            metalness={0.92}
            roughness={0.22}
            clearcoat={1}
            clearcoatRoughness={0.12}
          />
        </mesh>
        {/* screen frame */}
        <mesh position={[0, 0, 0.091]}>
          <planeGeometry args={[1.48, 3.08]} />
          <meshStandardMaterial color="#050508" />
        </mesh>
        {/* hero event "card" on screen — glowing gradient */}
        <mesh position={[0, 0.5, 0.095]}>
          <planeGeometry args={[1.32, 1.4]} />
          <meshBasicMaterial color="#FFD60A" transparent opacity={0.18} />
        </mesh>
        <mesh position={[0, 0.5, 0.096]}>
          <planeGeometry args={[1.2, 0.6]} />
          <meshBasicMaterial color="#FFD60A" transparent opacity={0.4} />
        </mesh>
        {/* rows */}
        <mesh position={[0, -0.6, 0.095]}>
          <planeGeometry args={[1.32, 0.34]} />
          <meshBasicMaterial color="#1c1c24" />
        </mesh>
        <mesh position={[0, -1.05, 0.095]}>
          <planeGeometry args={[1.32, 0.34]} />
          <meshBasicMaterial color="#1c1c24" />
        </mesh>
        {/* camera notch */}
        <mesh position={[0, 1.4, 0.1]}>
          <boxGeometry args={[0.42, 0.12, 0.02]} />
          <meshStandardMaterial color="#000" />
        </mesh>
        {/* rim light */}
        <mesh position={[0, 0, 0]} scale={[1.01, 1.01, 1]}>
          <boxGeometry args={[1.6, 3.2, 0.18]} />
          <meshBasicMaterial color="#FFD60A" transparent opacity={0.08} />
        </mesh>
      </group>
    </Float>
  );
}

export default function DeviceScene() {
  const pointer = useRef({ x: 0, y: 0 });
  const scrollY = useRef(0);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    function onMove(e: PointerEvent) {
      pointer.current = {
        x: (e.clientX / window.innerWidth) * 2 - 1,
        y: (e.clientY / window.innerHeight) * 2 - 1,
      };
    }
    function onScroll() { scrollY.current = window.scrollY; }
    window.addEventListener("pointermove", onMove);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => {
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  if (!mounted) return <div className="w-full h-full" />;

  return (
    <Canvas
      camera={{ position: [0, 0, 5], fov: 35 }}
      dpr={[1, 2]}
      gl={{ antialias: true, alpha: true }}
    >
      <ambientLight intensity={0.35} />
      <directionalLight position={[5, 5, 5]} intensity={1.2} color="#FFD60A" />
      <directionalLight position={[-4, -2, 3]} intensity={0.5} color="#6F4BE8" />
      <Environment preset="studio" />
      <Phone pointer={pointer} scrollY={scrollY} />
      <ContactShadows position={[0, -2.3, 0]} opacity={0.6} scale={7} blur={2} far={4} />
    </Canvas>
  );
}
