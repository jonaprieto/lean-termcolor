/-
Copyright (c) 2026 Jonathan Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Cubides
-/

import TermColor.Ansi

/-!
# TermColor.Text: styled text and spans

`Text` is a sequence of styled segments. The representation is deliberately small and
transparent: append preserves order, and rendering is a pure fold over the segments.
-/

namespace TermColor

/-- One piece of text with one style overlay. -/
structure Segment where
  text : String
  style : Style := {}
  deriving BEq, DecidableEq, Repr

/-- Text with styles attached to segments. -/
structure Text where
  segments : List Segment := []
  deriving BEq, DecidableEq, Repr

namespace Text

def empty : Text := {}

/-- Unstyled text. -/
def plain (text : String) : Text := { segments := [{ text := text }] }

/-- Text with one style overlay. -/
def styled (text : String) (style : Style) : Text := { segments := [{ text, style }] }

/-- Append two text values without changing their styles. -/
def append (left right : Text) : Text := { segments := left.segments ++ right.segments }

-- ponytail: list segments keep proofs simple; use a builder only if profiling finds
-- large incremental appends on the same value matter.

instance : EmptyCollection Text where emptyCollection := empty
instance : Append Text where append := append

/-- Concatenate text values in order. -/
def concat (texts : List Text) : Text := { segments := texts.flatMap (·.segments) }

/-- Style every character of a string from its index and the total character count. -/
def perChar (text : String) (style : Nat → Nat → Style) : Text :=
  let chars := text.toList
  { segments := chars.mapIdx fun i c => { text := c.toString, style := style i chars.length } }

/-- Sweep the hue wheel across the characters of a string. -/
def rainbow (text : String) : Text :=
  perChar text fun i n => Style.fg (Color.hue (i * 330 / max n 1))

def join : List String → String
  | [] => ""
  | text :: texts => text ++ join texts

/-- Remove all ANSI styling while preserving the visible text. -/
def plainText (text : Text) : String :=
  join (text.segments.map fun segment => segment.text)

/-- Render styled text for an explicit terminal target. -/
def render (target : RenderTarget) (text : Text) : String :=
  join (text.segments.map (fun segment => segment.style.wrap target segment.text))

/-- A convenient style application constructor. -/
def withStyle (style : Style) (text : String) : Text := styled text style

end Text

end TermColor
