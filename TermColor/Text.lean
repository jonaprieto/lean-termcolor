/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
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
  /-- Visible text in the segment. -/
  text : String
  /-- Style applied to the segment. -/
  style : Style := {}
  /-- Optional OSC-8 hyperlink URI. -/
  link : Option String := none
  deriving BEq, DecidableEq, Repr

/-- Text with styles attached to segments. -/
structure Text where
  /-- Ordered styled segments. -/
  segments : List Segment := []
  deriving BEq, DecidableEq, Repr

namespace Text

/-- An empty text value. -/
def empty : Text := {}

/-- Unstyled text. -/
def plain (text : String) : Text := { segments := [{ text := text }] }

/-- Text with one style overlay. -/
def styled (text : String) (style : Style) : Text := { segments := [{ text, style }] }

/-- Attach a terminal hyperlink to all segments in a text value. -/
def hyperlink (uri : String) (text : Text) : Text :=
  { segments := text.segments.map fun segment => { segment with link := some uri } }

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
  let count := chars.length
  { segments := chars.mapIdx fun i c => { text := c.toString, style := style i count } }

/-- Sweep the hue wheel across the characters of a string. -/
def rainbow (text : String) : Text :=
  perChar text fun i n => Style.fg (Color.hue (i * 330 / max n 1))

/-- Remove all ANSI styling while preserving the visible text. -/
def plainText (text : Text) : String :=
  String.join (text.segments.map fun segment => segment.text)

/-- Render styled text for an explicit terminal target. -/
private def safeUri (uri : String) : Bool :=
  !uri.contains "\u001b" && !uri.contains "\u0007"

/-- Render one segment for a terminal target. -/
def renderSegment (target : RenderTarget) (segment : Segment) : String :=
  let content := segment.style.wrap target segment.text
  match segment.link with
  | some uri =>
      if target.hyperlinks && safeUri uri then
        "\u001b]8;;" ++ uri ++ "\u001b\\" ++ content ++ "\u001b]8;;\u001b\\"
      else
        content
  | none => content

/-- Plain targets preserve text and suppress both styles and hyperlinks. -/
@[simp] theorem renderSegment_plain (segment : Segment) :
    renderSegment RenderTarget.plain segment = segment.text := by
  cases segment with
  | mk text style link =>
      cases link <;>
        by_cases h : text = "" <;>
          simp [h, renderSegment, RenderTarget.plain, Style.wrap, Style.sgr,
            Style.sgrParameters, String.isEmpty]

/-- Render styled text, optionally emitting OSC-8 hyperlinks for linked segments. -/
def render (target : RenderTarget) (text : Text) : String :=
  String.join (text.segments.map fun segment => renderSegment target segment)

end Text

end TermColor
