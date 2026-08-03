/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor

/-!
# TermColor.Properties.Basic: laws of style composition and rendering

These theorems are kept out of the executable library. The core needs no mathlib; this module
is the first home for its machine-checked algebraic contract.
-/

namespace TermColor

open Style
open scoped TermColor.Style

theorem style_empty_left (style : Style) : empty <+> style = style := by
  cases style
  simp [Style.combine, Style.empty]

theorem style_empty_right (style : Style) : style <+> empty = style := by
  cases style
  simp [Style.combine, Style.empty]

theorem style_combine_assoc (left middle right : Style) :
    (left <+> middle) <+> right = left <+> (middle <+> right) := by
  cases left
  cases middle
  cases right
  simp [Style.combine, List.append_assoc]

private theorem foldl_append_left (init : String) (texts : List String) :
    texts.foldl (· ++ ·) init = init ++ texts.foldl (· ++ ·) "" := by
  induction texts generalizing init with
  | nil => simp
  | cons first rest ih =>
      rw [List.foldl_cons, List.foldl_cons, ih (init ++ first), ih ("" ++ first)]
      simp [String.append_assoc]

theorem join_append (left right : List String) :
    String.join (left ++ right) = String.join left ++ String.join right := by
  simp [String.join, List.foldl_append, foldl_append_left (left.foldl (· ++ ·) "")]

theorem render_plain (text : Text) : Text.render .plain text = text.plainText := by
  simp [Text.render, Text.plainText, Text.renderSegment_plain]

theorem concat_append (left right : List Text) :
    Text.concat (left ++ right) = Text.concat left ++ Text.concat right := by
  change _ = Text.append _ _
  simp [Text.concat, Text.append, List.flatMap_append]

theorem render_append (target : RenderTarget) (left right : Text) :
    Text.render target (left ++ right) = Text.render target left ++ Text.render target right := by
  change Text.render target (Text.append left right) = _
  simp [Text.render, Text.append, List.map_append, join_append]

end TermColor
