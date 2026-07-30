/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Color

/-!
# TermColor.ColorScheme: semantic color palettes

`ColorScheme` collects the colors commonly needed by terminal UIs. The presets use true-color
values; rendering still decides how to fall back for the target terminal.
-/

namespace TermColor

/-- Semantic colors shared by the built-in terminal palettes. -/
structure ColorScheme where
  background : Color
  foreground : Color
  selection : Color
  comment : Color
  red : Color
  orange : Color
  yellow : Color
  green : Color
  cyan : Color
  blue : Color
  purple : Color
  pink : Color
  deriving BEq, DecidableEq, Repr

namespace ColorScheme

/-- Catppuccin Mocha. -/
def catppuccin : ColorScheme where
  background := .rgb 30 30 46
  foreground := .rgb 205 214 244
  selection := .rgb 88 91 112
  comment := .rgb 108 112 134
  red := .rgb 243 139 168
  orange := .rgb 250 179 135
  yellow := .rgb 249 226 175
  green := .rgb 166 227 161
  cyan := .rgb 148 226 213
  blue := .rgb 137 180 250
  purple := .rgb 203 166 247
  pink := .rgb 245 194 231

/-- The official Dracula palette. -/
def dracula : ColorScheme where
  background := .rgb 40 42 54
  foreground := .rgb 248 248 242
  selection := .rgb 68 71 90
  comment := .rgb 98 114 164
  red := .rgb 255 85 85
  orange := .rgb 255 184 108
  yellow := .rgb 241 250 140
  green := .rgb 80 250 123
  cyan := .rgb 139 233 253
  blue := .rgb 139 233 253
  purple := .rgb 189 147 249
  pink := .rgb 255 121 198

/-- The classic Monokai palette. -/
def monokai : ColorScheme where
  background := .rgb 39 40 34
  foreground := .rgb 248 248 242
  selection := .rgb 73 72 62
  comment := .rgb 117 113 94
  red := .rgb 249 38 114
  orange := .rgb 253 151 31
  yellow := .rgb 230 219 116
  green := .rgb 166 226 46
  cyan := .rgb 161 239 228
  blue := .rgb 102 217 239
  purple := .rgb 174 129 255
  pink := .rgb 249 38 114

end ColorScheme

end TermColor
