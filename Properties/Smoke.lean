/-
Copyright (c) 2026 Jonathan Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Cubides
-/

import Properties.Basic

namespace TermColor

open Style
open scoped TermColor.Style

#guard Color.red == Color.ansi .normal .red
#guard Color.brightBlue == Color.ansi .bright .blue
#guard Color.rgbToAnsi256 255 0 0 == 196
#guard Color.rgbToAnsi256 128 128 128 == 244
#guard Color.ansi256Rgb 196 == (255, 0, 0)
#guard Color.rgbToAnsi16 255 0 0 == 9
#guard Color.toAnsi16 (.indexed 196) == some 9
#guard Style.sgr RenderTarget.ansi16 (Style.bold <+> Style.red) == "\u001b[1;31m"
#guard Style.wrap RenderTarget.plain Style.bold "hello" == "hello"
#guard Text.plainText (Text.styled "a" Style.red ++ Text.plain "b") == "ab"
#guard Text.render RenderTarget.plain (Text.styled "a" Style.red ++ Text.plain "b") == "ab"
#guard Text.render RenderTarget.ansi16 (Text.styled "a" Style.red) == "\u001b[31ma\u001b[0m"

end TermColor
