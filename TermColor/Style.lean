/-
Copyright (c) 2026 Jonathan Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Cubides
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
  | bold
  | dim
  | italic
  | underline
  | blink
  | rapidBlink
  | reverse
  | conceal
  | strike
  | doubleUnderline
  | framed
  | encircled
  | overlined
  deriving BEq, DecidableEq, Repr

/-- One setting in a style sequence. -/
inductive Setting where
  | foreground : Color → Setting
  | background : Color → Setting
  | attr : Attribute → Bool → Setting
  deriving BEq, DecidableEq, Repr

/-- A composable sequence of terminal settings. -/
structure Style where
  settings : List Setting := []
  deriving BEq, DecidableEq, Repr

namespace Style

/-- The empty style sequence. -/
def empty : Style := {}

/-- Concatenate style settings. Later settings are applied later by the terminal. -/
def combine (old new : Style) : Style := { settings := old.settings ++ new.settings }

scoped infixl:65 " <+> " => combine

private def setAttribute (kind : Attribute) (enabled : Bool) : Style :=
  { settings := [.attr kind enabled] }

/-- A foreground-color setting. -/
def fg (color : Color) : Style := { settings := [.foreground color] }

/-- A background-color setting. -/
def bg (color : Color) : Style := { settings := [.background color] }

/-- Turn one attribute on. -/
def bold : Style := setAttribute .bold true
def dim : Style := setAttribute .dim true
def italic : Style := setAttribute .italic true
def underline : Style := setAttribute .underline true
def blink : Style := setAttribute .blink true
def rapidBlink : Style := setAttribute .rapidBlink true
def reverse : Style := setAttribute .reverse true
def conceal : Style := setAttribute .conceal true
def strike : Style := setAttribute .strike true
def doubleUnderline : Style := setAttribute .doubleUnderline true
def framed : Style := setAttribute .framed true
def encircled : Style := setAttribute .encircled true
def overlined : Style := setAttribute .overlined true

/-- Turn one attribute off in an overlay. -/
def notBold : Style := setAttribute .bold false
def notDim : Style := setAttribute .dim false
def notItalic : Style := setAttribute .italic false
def notUnderline : Style := setAttribute .underline false
def notBlink : Style := setAttribute .blink false
def notRapidBlink : Style := setAttribute .rapidBlink false
def notReverse : Style := setAttribute .reverse false
def notConceal : Style := setAttribute .conceal false
def notStrike : Style := setAttribute .strike false
def notDoubleUnderline : Style := setAttribute .doubleUnderline false
def notFramed : Style := setAttribute .framed false
def notEncircled : Style := setAttribute .encircled false
def notOverlined : Style := setAttribute .overlined false

def black : Style := fg .black
def red : Style := fg .red
def green : Style := fg .green
def yellow : Style := fg .yellow
def blue : Style := fg .blue
def magenta : Style := fg .magenta
def cyan : Style := fg .cyan
def white : Style := fg .white
def onBlack : Style := bg .black
def onRed : Style := bg .red
def onGreen : Style := bg .green
def onYellow : Style := bg .yellow
def onBlue : Style := bg .blue
def onMagenta : Style := bg .magenta
def onCyan : Style := bg .cyan
def onWhite : Style := bg .white

end Style

end TermColor
