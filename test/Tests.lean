/-
Copyright (c) 2026 Jonathan Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Cubides
-/

import TermColor

/-! Small executable checks for the public foundation API. Laws with proof content live in
`TermColor.Properties`; these checks cover the package's plain-text and rendering boundary. -/

open TermColor

#guard (Text.plain "hello").plainText == "hello"
#guard (Text.render RenderTarget.plain (Text.styled "hello" Style.bold)) == "hello"
#guard (Text.render RenderTarget.ansi16 (Text.styled "hello" Style.bold)).contains "hello"
#guard Color.rgbToAnsi256 255 0 0 == 196

/-- Run the executable foundation checks. -/
def main : IO UInt32 := do
  IO.println "termcolor checks passed"
  pure 0
