/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor
import TermColor.Detect

open TermColor
open scoped TermColor.Style

/-! A tour of everything `TermColor` can put on a terminal. -/

private def demoPalette : ColorScheme := ColorScheme.catppuccin

private def label (name : String) : Text :=
  Text.styled (name ++ "".pushn ' ' (11 - name.length)) (Style.fg demoPalette.comment)

private def row (name : String) (cells : List Text) : Text :=
  label name ++ Text.concat cells ++ Text.plain "\n"

/-- A row of colored blocks, `count` wide. -/
private def bar (count : Nat) (color : Nat → Nat → Color) : Text :=
  Text.perChar ("".pushn ' ' count) fun i n => Style.bg (color i n)

private def attributes : List (String × Style) :=
  [ ("bold", Style.bold), ("dim", Style.dim), ("italic", Style.italic)
  , ("underline", Style.underline), ("double", Style.doubleUnderline)
  , ("blink", Style.blink), ("reverse", Style.reverse), ("strike", Style.strike)
  , ("overline", Style.overlined), ("framed", Style.framed), ("conceal", Style.conceal) ]

private def basics : List (String × BasicColor) :=
  [ ("black", .black), ("red", .red), ("green", .green), ("yellow", .yellow)
  , ("blue", .blue), ("magenta", .magenta), ("cyan", .cyan), ("white", .white) ]

private def words (cells : List Text) : List Text :=
  cells.map (· ++ Text.plain " ")

private def levelName : ColorLevel → String
  | .none => "none"
  | .ansi16 => "16 colors"
  | .ansi256 => "256 colors"
  | .trueColor => "true color (24 bit)"

private def heading (title : String) : Text :=
  Text.plain "\n" ++
    Text.styled title (Style.bold <+> Style.fg demoPalette.foreground) ++ Text.plain "\n"

private def demo (target : RenderTarget) : Text := Text.concat
  [ Text.rainbow "termcolor"
  , Text.styled "  ANSI styling for Lean 4\n" (Style.dim <+> Style.fg demoPalette.comment)
  , heading "attributes"
  , row "all" (words (attributes.map fun (name, style) => Text.styled name style))
  , heading "colors"
  , row "foreground" (words (basics.map fun (name, c) =>
      Text.styled name (Style.fg (.ansi .normal c))))
  , row "bright" (words (basics.map fun (name, c) =>
      Text.styled name (Style.fg (.ansi .bright c))))
  , row "background" (words (basics.map fun (name, c) =>
      Text.styled name (Style.bg (.ansi .normal c) <+> Style.fg .black)))
  , heading "256 color palette"
  , row "cube" [bar 36 fun i _ => .indexed (UInt8.ofNat (16 + i * 6))]
  , row "grays" [bar 24 fun i _ => .indexed (UInt8.ofNat (232 + i))]
  , heading "true color"
  , row "hue" [bar 72 fun i n => Color.hue (i * 360 / n)]
  , row "fade" [bar 72 fun i n =>
      .rgb (UInt8.ofNat (i * 255 / (n - 1))) 64 (UInt8.ofNat (255 - i * 255 / (n - 1)))]
  , heading "composition"
  , row "styled" [ Text.styled "hello" (Style.bold <+> Style.fg demoPalette.cyan)
                 , Text.styled " world" Style.underline ]
  , row "nested" [ Text.styled "warning" (Style.bold <+> Style.fg demoPalette.orange)
                 , Text.plain ": "
                 , Text.styled "disk almost full" Style.italic ]
  , row "rainbow" [Text.rainbow "dependent types make terminals pretty"]
  , heading "target"
  , row "detected" [Text.plain (levelName target.colors)]
  , row "styles" [Text.plain (if target.styles then "enabled" else "disabled")]
  , Text.styled "\nNO_COLOR=1 or a pipe strips every escape above.\n"
      (Style.dim <+> Style.fg demoPalette.comment)
  ]

def main : IO Unit := do
  let target ← TermColor.target
  IO.print (Text.render target (demo target))
