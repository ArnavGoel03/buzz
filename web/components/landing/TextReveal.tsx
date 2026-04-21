"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";

// Word-by-word blur + translate reveal when the element enters the viewport.
// Used on hero headlines, section titles, pull quotes.
export default function TextReveal({
  text,
  className,
  delay = 0,
  stagger = 0.04,
}: {
  text: string;
  className?: string;
  delay?: number;
  stagger?: number;
}) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, amount: 0.3 });
  const words = text.split(" ");

  return (
    <span ref={ref} className={className} style={{ display: "inline-block" }}>
      {words.map((word, i) => (
        <motion.span
          key={`${word}-${i}`}
          style={{ display: "inline-block", whiteSpace: "pre" }}
          initial={{ opacity: 0, y: 12, filter: "blur(12px)" }}
          animate={
            inView
              ? { opacity: 1, y: 0, filter: "blur(0px)" }
              : { opacity: 0, y: 12, filter: "blur(12px)" }
          }
          transition={{
            duration: 0.7,
            delay: delay + i * stagger,
            ease: [0.16, 1, 0.3, 1],
          }}
        >
          {word + (i < words.length - 1 ? " " : "")}
        </motion.span>
      ))}
    </span>
  );
}
