/-
Copyright (c) 2026 Jonathan Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Cubides
-/

import TermColor.Style

/-!
# TermColor.Ansi: pure ANSI SGR encoding

This module has no terminal detection and performs no IO. A `RenderTarget` makes the fallback
policy explicit, so the same styled value can be rendered as plain text, ANSI-16, ANSI-256, or
true color.
-/

namespace TermColor

/-- Whether styles are emitted, and how much color precision is available. -/
structure RenderTarget where
  styles : Bool := true
  colors : ColorLevel := .trueColor
  deriving BEq, DecidableEq, Repr

namespace RenderTarget

def plain : RenderTarget := { styles := false, colors := .none }
def ansi16 : RenderTarget := { styles := true, colors := .ansi16 }
def ansi256 : RenderTarget := { styles := true, colors := .ansi256 }
def trueColor : RenderTarget := { styles := true, colors := .trueColor }

end RenderTarget

inductive Layer where
  | foreground
  | background
  deriving BEq, DecidableEq, Repr

namespace Color

private def ansiCode (layer : Layer) (index : UInt8) : Nat :=
  let base := match layer with | .foreground => 30 | .background => 40
  base + index.toNat

private def brightCode (layer : Layer) (index : UInt8) : Nat :=
  let base := match layer with | .foreground => 90 | .background => 100
  base + index.toNat - 8

private def ansi16Codes (layer : Layer) : Color → List Nat
  | .default => [match layer with | .foreground => 39 | .background => 49]
  | .ansi intensity basic =>
      let i := ansiIndex intensity basic
      [if i < 8 then ansiCode layer i else brightCode layer i]
  | .indexed index =>
      if index < 16 then
        [if index < 8 then ansiCode layer index else brightCode layer index]
      else
        let rgb := ansi256Rgb index
        let i := rgbToAnsi16 (UInt8.ofNat rgb.1) (UInt8.ofNat rgb.2.1) (UInt8.ofNat rgb.2.2)
        [if i < 8 then ansiCode layer i else brightCode layer i]
  | .rgb r g b =>
      let i := rgbToAnsi16 r g b
      [if i < 8 then ansiCode layer i else brightCode layer i]

private def ansi256Codes (layer : Layer) : Color → List Nat
  | .default => [match layer with | .foreground => 39 | .background => 49]
  | .ansi intensity basic =>
      let i := ansiIndex intensity basic
      [if i < 8 then ansiCode layer i else brightCode layer i]
  | color =>
      let i := color.toAnsi256.getD 0
      match layer with
      | .foreground => [38, 5, i.toNat]
      | .background => [48, 5, i.toNat]

private def trueColorCodes (layer : Layer) : Color → List Nat
  | .default => [match layer with | .foreground => 39 | .background => 49]
  | .ansi intensity basic =>
      let i := ansiIndex intensity basic
      [if i < 8 then ansiCode layer i else brightCode layer i]
  | .indexed index =>
      match layer with
      | .foreground => [38, 5, index.toNat]
      | .background => [48, 5, index.toNat]
  | .rgb r g b =>
      match layer with
      | .foreground => [38, 2, r.toNat, g.toNat, b.toNat]
      | .background => [48, 2, r.toNat, g.toNat, b.toNat]

/-- Encode a color for one SGR layer at a given terminal color level. -/
def sgrCodes (layer : Layer) (level : ColorLevel) (color : Color) : List Nat :=
  match level with
  | .none => []
  | .ansi16 => ansi16Codes layer color
  | .ansi256 => ansi256Codes layer color
  | .trueColor => trueColorCodes layer color

end Color

namespace Style

private def attributeCodes : Attribute → Bool → List Nat
  | .bold, true => [1]
  | .bold, false => [22]
  | .dim, true => [2]
  | .dim, false => [22]
  | .italic, true => [3]
  | .italic, false => [23]
  | .underline, true => [4]
  | .underline, false => [24]
  | .blink, true => [5]
  | .blink, false => [25]
  | .rapidBlink, true => [6]
  | .rapidBlink, false => [25]
  | .reverse, true => [7]
  | .reverse, false => [27]
  | .conceal, true => [8]
  | .conceal, false => [28]
  | .strike, true => [9]
  | .strike, false => [29]
  | .doubleUnderline, true => [21]
  | .doubleUnderline, false => [24]
  | .framed, true => [51]
  | .framed, false => [54]
  | .encircled, true => [52]
  | .encircled, false => [54]
  | .overlined, true => [53]
  | .overlined, false => [55]

private def settingCodes (target : RenderTarget) : Setting → List Nat
  | .foreground color => Color.sgrCodes .foreground target.colors color
  | .background color => Color.sgrCodes .background target.colors color
  | .attr kind enabled => attributeCodes kind enabled

private def joinWith (_ : String) : List String → String
  | [] => ""
  | [x] => x
  | x :: xs => x ++ ";" ++ joinWith ";" xs

private def codesToString (codes : List Nat) : String :=
  joinWith ";" (codes.map toString)

/-- The SGR parameter string for a style at a target capability. -/
def sgrParameters (target : RenderTarget) (style : Style) : List Nat :=
  if !target.styles then []
  else
    style.settings.flatMap (settingCodes target)

/-- Encode a style as an SGR opening sequence. -/
def sgr (target : RenderTarget) (style : Style) : String :=
  let codes := sgrParameters target style
  if codes.isEmpty then ""
  else "\u001b[" ++ codesToString codes ++ "m"

/-- Reset all SGR attributes and colors. -/
def reset : String := "\u001b[0m"

/-- Wrap plain text in an opening SGR sequence and a complete reset. -/
def wrap (target : RenderTarget) (style : Style) (text : String) : String :=
  if text.isEmpty then ""
  else
    let opening := sgr target style
    if opening.isEmpty then text else opening ++ text ++ reset

end Style

end TermColor
