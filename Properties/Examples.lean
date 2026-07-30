/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import Properties.Basic

/-!
# TermColor.Properties.Examples: concrete API lemmas

These small named lemmas document and check the public examples used in the README. They are
theorem statements, not a separate runtime test suite.
-/

namespace TermColor

open Style
open scoped TermColor.Style

theorem red_is_normal_ansi : Color.red = Color.ansi .normal .red := by
  rfl

theorem bright_blue_is_bright_ansi : Color.brightBlue = Color.ansi .bright .blue := by
  rfl

theorem rgb_red_uses_xterm_196 : Color.rgbToAnsi256 255 0 0 = 196 := by
  decide

theorem gray_128_uses_xterm_244 : Color.rgbToAnsi256 128 128 128 = 244 := by
  decide

theorem xterm_196_is_red : Color.ansi256Rgb 196 = (255, 0, 0) := by
  decide

theorem rgb_red_is_bright_red : Color.rgbToAnsi16 255 0 0 = 9 := by
  decide

theorem indexed_red_downgrades_to_bright_red :
    Color.toAnsi16 (.indexed 196) = some 9 := by
  decide

theorem bold_red_ansi16 :
    Style.sgr RenderTarget.ansi16 (Style.bold <+> Style.red) = "\u001b[1;31m" := by
  decide

theorem plain_target_omits_ansi :
    Style.wrap RenderTarget.plain Style.bold "hello" = "hello" := by
  decide

theorem plain_text_forgets_styles :
    Text.plainText (Text.styled "a" Style.red ++ Text.plain "b") = "ab" := by
  decide

theorem plain_render_forgets_styles :
    Text.render RenderTarget.plain (Text.styled "a" Style.red ++ Text.plain "b") = "ab" := by
  decide

theorem ansi16_render_wraps_red :
    Text.render RenderTarget.ansi16 (Text.styled "a" Style.red) = "\u001b[31ma\u001b[0m" := by
  decide

end TermColor
