/* GENERATED from design/tokens.json. Do not edit by hand.
   Run `pnpm tokens` after editing tokens. */

/** Every colour in the design system, keyed the same way as the CSS variables. */
export const COLOR = {
  accent: "#FFD60A",
  accentBright: "#FFE34A",
  accentDim: "#FFD60A22",
  accentInk: "#000000",
  background: "#080808",
  backgroundElevated: "#141418",
  surface: "#1C1C22",
  surface2: "#242429",
  surface3: "#2D2D34",
  border: "#1F1F1F",
  borderStrong: "#2A2A2A",
  borderBright: "#3D3D3D",
  textPrimary: "#F5F5F7",
  textSecondary: "#A8A8AE",
  textTertiary: "#6B6B72",
  textQuaternary: "#48484A",
  live: "#FF3B30",
  categoryParty: "#FF2D92",
  categoryAcademic: "#0A85FF",
  categorySports: "#30D158",
  categoryFood: "#FF9F0A",
  categoryClub: "#BF59F2",
  categoryArts: "#63D2FF",
  categoryMusic: "#BFF233",
  categoryStudy: "#5E5CE6",
  categoryWellness: "#FF7373",
} as const;

export const RADIUS = {
  sm: "10px",
  md: "14px",
  lg: "18px",
  xl: "24px",
} as const;

export const SPACING = {
  xs: "4px",
  sm: "8px",
  md: "16px",
  lg: "24px",
  xl: "32px",
} as const;

/**
 * The values that have to leave CSS: browser chrome, manifest, OG images, and the
 * rasterized app icons all need a literal string, not a custom property.
 */
export const BRAND_COLORS = {
  /** Browser chrome and the PWA splash background. */
  theme: COLOR.background,
  background: COLOR.background,
  accent: COLOR.accent,
  /** Text drawn on top of accent. */
  accentInk: COLOR.accentInk,
  text: COLOR.textPrimary,
  textMuted: COLOR.textSecondary,
  border: COLOR.borderStrong,
} as const;
