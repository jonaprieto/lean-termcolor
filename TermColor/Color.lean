/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

/-!
# TermColor.Color: colors and terminal color levels

`Color` describes a color independently of a terminal. Rendering chooses the strongest
representation the target terminal can accept: the eight ANSI colors, the xterm 256-color
palette, or 24-bit RGB. `default` means the terminal's configured default color.

The RGB-to-palette conversions use the conventional xterm palette. A terminal may let its
user redefine that palette, so RGB fallback is necessarily an approximation unless the caller
chooses a stronger target.
-/

namespace TermColor

/-- The eight ANSI color names. -/
inductive BasicColor where
  | /-- Black. -/ black
  | /-- Red. -/ red
  | /-- Green. -/ green
  | /-- Yellow. -/ yellow
  | /-- Blue. -/ blue
  | /-- Magenta. -/ magenta
  | /-- Cyan. -/ cyan
  | /-- White. -/ white
  deriving BEq, DecidableEq, Repr

/-- The two intensities of the eight ANSI colors. -/
inductive Intensity where
  | /-- Normal intensity. -/ normal
  | /-- Bright intensity. -/ bright
  deriving BEq, DecidableEq, Repr

/-- A color that can be represented by ANSI SGR color parameters. -/
inductive Color where
  | /-- The terminal's configured default color. -/ default
  | /-- An ANSI basic color at the given intensity. -/ ansi : Intensity → BasicColor → Color
  | /-- An xterm 256-color palette index. -/ indexed : UInt8 → Color
  | /-- An explicit red, green, and blue color. -/ rgb : UInt8 → UInt8 → UInt8 → Color
  deriving BEq, DecidableEq, Repr

namespace Color

/-- The ordinary ANSI colors. -/
def black : Color := .ansi .normal .black
/-- The ordinary red ANSI color. -/
def red : Color := .ansi .normal .red
/-- The ordinary green ANSI color. -/
def green : Color := .ansi .normal .green
/-- The ordinary yellow ANSI color. -/
def yellow : Color := .ansi .normal .yellow
/-- The ordinary blue ANSI color. -/
def blue : Color := .ansi .normal .blue
/-- The ordinary magenta ANSI color. -/
def magenta : Color := .ansi .normal .magenta
/-- The ordinary cyan ANSI color. -/
def cyan : Color := .ansi .normal .cyan
/-- The ordinary white ANSI color. -/
def white : Color := .ansi .normal .white

/-- The bright black ANSI color. -/
def brightBlack : Color := .ansi .bright .black
/-- The bright red ANSI color. -/
def brightRed : Color := .ansi .bright .red
/-- The bright green ANSI color. -/
def brightGreen : Color := .ansi .bright .green
/-- The bright yellow ANSI color. -/
def brightYellow : Color := .ansi .bright .yellow
/-- The bright blue ANSI color. -/
def brightBlue : Color := .ansi .bright .blue
/-- The bright magenta ANSI color. -/
def brightMagenta : Color := .ansi .bright .magenta
/-- The bright cyan ANSI color. -/
def brightCyan : Color := .ansi .bright .cyan
/-- The bright white ANSI color. -/
def brightWhite : Color := .ansi .bright .white

/-- The fully saturated, full-brightness color at a hue given in degrees.

The hue wheel wraps, so any `Nat` is a valid argument. Saturation and value are fixed at their
maximum, which is what gradients and rainbows want; for anything else build `.rgb` directly.
-/
def hue (degrees : Nat) : Color :=
  let ramp : UInt8 := UInt8.ofNat (degrees % 60 * 255 / 60)
  match (degrees / 60) % 6 with
  | 0 => .rgb 255 ramp 0
  | 1 => .rgb (255 - ramp) 255 0
  | 2 => .rgb 0 255 ramp
  | 3 => .rgb 0 (255 - ramp) 255
  | 4 => .rgb ramp 0 255
  | _ => .rgb 255 0 (255 - ramp)

private def basicIndex : BasicColor → Nat
  | .black => 0
  | .red => 1
  | .green => 2
  | .yellow => 3
  | .blue => 4
  | .magenta => 5
  | .cyan => 6
  | .white => 7

/-- The xterm index of an ANSI color. -/
def ansiIndex : Intensity → BasicColor → UInt8
  | .normal, c => UInt8.ofNat (basicIndex c)
  | .bright, c => UInt8.ofNat (8 + basicIndex c)

/-- The three channels of the conventional xterm ANSI-16 palette. -/
private def ansi16Rgb : Nat → Nat × Nat × Nat
  | 0  => (0, 0, 0)
  | 1  => (128, 0, 0)
  | 2  => (0, 128, 0)
  | 3  => (128, 128, 0)
  | 4  => (0, 0, 128)
  | 5  => (128, 0, 128)
  | 6  => (0, 128, 128)
  | 7  => (192, 192, 192)
  | 8  => (128, 128, 128)
  | 9  => (255, 0, 0)
  | 10 => (0, 255, 0)
  | 11 => (255, 255, 0)
  | 12 => (0, 0, 255)
  | 13 => (255, 0, 255)
  | 14 => (0, 255, 255)
  | _  => (255, 255, 255)

private def absDiff (left right : Nat) : Nat :=
  if left < right then right - left else left - right

private def distance (r g b : Nat) (palette : Nat × Nat × Nat) : Nat :=
  let dr := absDiff r palette.1
  let dg := absDiff g palette.2.1
  let db := absDiff b palette.2.2
  dr * dr + dg * dg + db * db

private def nearestAnsi16 (r g b : Nat) : UInt8 :=
  let rec loop (remaining candidate best bestDistance : Nat) : Nat :=
    match remaining with
    | 0 => best
    | remaining + 1 =>
        let d := distance r g b (ansi16Rgb candidate)
        if d < bestDistance then loop remaining (candidate + 1) candidate d
        else loop remaining (candidate + 1) best bestDistance
  UInt8.ofNat (loop 15 1 0 (distance r g b (ansi16Rgb 0)))

private def channel6 (x : UInt8) : Nat := (x.toNat * 5 + 127) / 255

/-- The xterm 256-color index nearest to an RGB color.

The 6×6×6 cube is used for chromatic colors and the 8..238 grayscale ramp for exact grays;
pure black and white use the exact ANSI-16 endpoints.
-/
def rgbToAnsi256 (r g b : UInt8) : UInt8 :=
  if r == g && g == b then
    if r.toNat < 8 then 16
    else if r.toNat > 248 then 231
    else UInt8.ofNat (232 + min 23 ((r.toNat - 8 + 5) / 10))
  else
    UInt8.ofNat (16 + 36 * channel6 r + 6 * channel6 g + channel6 b)

private def cubeChannel : Nat → Nat
  | 0 => 0
  | level => 55 + 40 * level

/-- The conventional RGB value represented by an xterm 256-color index. -/
def ansi256Rgb (index : UInt8) : Nat × Nat × Nat :=
  let i := index.toNat
  if i < 16 then ansi16Rgb i
  else if i < 232 then
    let cube := i - 16
    (cubeChannel (cube / 36), cubeChannel ((cube / 6) % 6), cubeChannel (cube % 6))
  else
    let gray := 8 + 10 * (i - 232)
    (gray, gray, gray)

/-- The ANSI-16 index nearest to an RGB color, using the conventional xterm palette. -/
def rgbToAnsi16 (r g b : UInt8) : UInt8 := nearestAnsi16 r.toNat g.toNat b.toNat

/-- The xterm 256-color index represented by a color when a palette fallback is needed. -/
def toAnsi256 : Color → Option UInt8
  | .default => none
  | .ansi i c => some (ansiIndex i c)
  | .indexed i => some i
  | .rgb r g b => some (rgbToAnsi256 r g b)

/-- The ANSI-16 index represented by a color when only the basic palette is available. -/
def toAnsi16 : Color → Option UInt8
  | .default => none
  | .ansi i c => some (ansiIndex i c)
  | .indexed i =>
      let rgb := ansi256Rgb i
      some (rgbToAnsi16 (UInt8.ofNat rgb.1) (UInt8.ofNat rgb.2.1) (UInt8.ofNat rgb.2.2))
  | .rgb r g b => some (rgbToAnsi16 r g b)

end Color

/-! ### Terminal color levels -/

/-- The color precision a terminal can receive through SGR. -/
inductive ColorLevel where
  | /-- Do not emit color codes. -/ none
  | /-- Emit the ANSI-16 palette. -/ ansi16
  | /-- Emit the xterm 256-color palette. -/ ansi256
  | /-- Emit 24-bit RGB colors. -/ trueColor
  deriving BEq, DecidableEq, Repr

end TermColor
