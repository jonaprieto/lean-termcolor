/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Color

/-!
# TermColor.Style: composable terminal styles

A style is a sequence of SGR settings. An attribute setting carries either `true` or `false`,
so it can enable or disable a surrounding attribute; an absent setting means inherit. Settings
are applied from left to right, and later settings therefore take precedence for overlapping
properties. This is the same small algebra used by ANSI itself.
-/

namespace TermColor

/-- The text attributes represented by common SGR terminals. -/
inductive Attribute where
  | /-- Bold text. -/ bold
  | /-- Dim text. -/ dim
  | /-- Italic text. -/ italic
  | /-- Underlined text. -/ underline
  | /-- Blinking text. -/ blink
  | /-- Rapidly blinking text. -/ rapidBlink
  | /-- Reversed foreground and background. -/ reverse
  | /-- Concealed text. -/ conceal
  | /-- Struck-through text. -/ strike
  | /-- Double-underlined text. -/ doubleUnderline
  | /-- Framed text. -/ framed
  | /-- Encircled text. -/ encircled
  | /-- Overlined text. -/ overlined
  deriving BEq, DecidableEq, Repr

/-- One setting in a style sequence. -/
inductive Setting where
  | /-- Set the foreground color. -/ foreground : Color → Setting
  | /-- Set the background color. -/ background : Color → Setting
  | /-- Enable or disable an attribute. -/ attr : Attribute → Bool → Setting
  deriving BEq, DecidableEq, Repr

/-- A composable sequence of terminal settings. -/
structure Style where
  /-- Settings applied from left to right. -/
  settings : List Setting := []
  deriving BEq, DecidableEq, Repr

namespace Style

/-- The empty style sequence. -/
def empty : Style := {}

/-- Concatenate style settings. Later settings are applied later by the terminal. -/
def combine (old new : Style) : Style := { settings := old.settings ++ new.settings }

/-- Combine styles, applying the right-hand settings after the left-hand settings. -/
scoped infixl:65 " <+> " => combine

private def setAttribute (kind : Attribute) (enabled : Bool) : Style :=
  { settings := [.attr kind enabled] }

/-- A foreground-color setting. -/
def fg (color : Color) : Style := { settings := [.foreground color] }

/-- A background-color setting. -/
def bg (color : Color) : Style := { settings := [.background color] }

/-- Turn one attribute on. -/
def bold : Style := setAttribute .bold true
/-- Turn dim text on. -/
def dim : Style := setAttribute .dim true
/-- Turn italic text on. -/
def italic : Style := setAttribute .italic true
/-- Turn underlining on. -/
def underline : Style := setAttribute .underline true
/-- Turn blinking on. -/
def blink : Style := setAttribute .blink true
/-- Turn rapid blinking on. -/
def rapidBlink : Style := setAttribute .rapidBlink true
/-- Turn reverse video on. -/
def reverse : Style := setAttribute .reverse true
/-- Turn concealment on. -/
def conceal : Style := setAttribute .conceal true
/-- Turn strike-through on. -/
def strike : Style := setAttribute .strike true
/-- Turn double underlining on. -/
def doubleUnderline : Style := setAttribute .doubleUnderline true
/-- Turn framing on. -/
def framed : Style := setAttribute .framed true
/-- Turn encircling on. -/
def encircled : Style := setAttribute .encircled true
/-- Turn overlining on. -/
def overlined : Style := setAttribute .overlined true

/-- Turn one attribute off in an overlay. -/
def notBold : Style := setAttribute .bold false
/-- Turn dim text off in an overlay. -/
def notDim : Style := setAttribute .dim false
/-- Turn italic text off in an overlay. -/
def notItalic : Style := setAttribute .italic false
/-- Turn underlining off in an overlay. -/
def notUnderline : Style := setAttribute .underline false
/-- Turn blinking off in an overlay. -/
def notBlink : Style := setAttribute .blink false
/-- Turn rapid blinking off in an overlay. -/
def notRapidBlink : Style := setAttribute .rapidBlink false
/-- Turn reverse video off in an overlay. -/
def notReverse : Style := setAttribute .reverse false
/-- Turn concealment off in an overlay. -/
def notConceal : Style := setAttribute .conceal false
/-- Turn strike-through off in an overlay. -/
def notStrike : Style := setAttribute .strike false
/-- Turn double underlining off in an overlay. -/
def notDoubleUnderline : Style := setAttribute .doubleUnderline false
/-- Turn framing off in an overlay. -/
def notFramed : Style := setAttribute .framed false
/-- Turn encircling off in an overlay. -/
def notEncircled : Style := setAttribute .encircled false
/-- Turn overlining off in an overlay. -/
def notOverlined : Style := setAttribute .overlined false

/-- A black foreground style. -/
def black : Style := fg .black
/-- A red foreground style. -/
def red : Style := fg .red
/-- A green foreground style. -/
def green : Style := fg .green
/-- A yellow foreground style. -/
def yellow : Style := fg .yellow
/-- A blue foreground style. -/
def blue : Style := fg .blue
/-- A magenta foreground style. -/
def magenta : Style := fg .magenta
/-- A cyan foreground style. -/
def cyan : Style := fg .cyan
/-- A white foreground style. -/
def white : Style := fg .white
/-- A black background style. -/
def onBlack : Style := bg .black
/-- A red background style. -/
def onRed : Style := bg .red
/-- A green background style. -/
def onGreen : Style := bg .green
/-- A yellow background style. -/
def onYellow : Style := bg .yellow
/-- A blue background style. -/
def onBlue : Style := bg .blue
/-- A magenta background style. -/
def onMagenta : Style := bg .magenta
/-- A cyan background style. -/
def onCyan : Style := bg .cyan
/-- A white background style. -/
def onWhite : Style := bg .white

end Style

end TermColor
