/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Text

/-!
# TermColor.Detect: conservative terminal selection and output

Detection follows common command-line conventions: `NO_COLOR` wins, a non-empty
`FORCE_COLOR` enables ANSI output even when stdout is redirected, and `TERM=dumb` disables
ANSI output. This is policy, not part of the pure rendering model, so callers can always pass
an explicit `RenderTarget` instead.
-/

namespace TermColor

inductive ColorChoice where
  | auto
  | always
  | never
  deriving BEq, DecidableEq, Repr

private def nonEmpty (value : Option String) : Bool :=
  match value with
  | some value => !value.isEmpty
  | none => false

private def detectedLevel (term colorterm : Option String) : ColorLevel :=
  match colorterm with
  | some value =>
      if value == "truecolor" || value == "24bit" then .trueColor else .ansi16
  | none =>
      match term with
      | some value => if value.endsWith "-256color" then .ansi256 else .ansi16
      | none => .ansi16

private def dumbTerm (term : Option String) : Bool :=
  match term with
  | some "dumb" | some "unknown" => true
  | _ => false

/-- Choose a render target from the current process environment and stdout. -/
def target (choice : ColorChoice := .auto) : IO RenderTarget := do
  let noColor := nonEmpty (← IO.getEnv "NO_COLOR")
  let forceColor := nonEmpty (← IO.getEnv "FORCE_COLOR")
  let term := ← IO.getEnv "TERM"
  let colorterm := ← IO.getEnv "COLORTERM"
  let tty ← (← IO.getStdout).isTty
  let level := detectedLevel term colorterm
  let forced := choice == .always || forceColor
  let active := forced || tty
  if choice == .never then
    pure .plain
  else if noColor then
    pure { styles := active, colors := .none }
  else if forced then
    pure { styles := true, colors := level }
  else if dumbTerm term then
    pure .plain
  else if tty then
    pure { styles := true, colors := level }
  else
    pure .plain

/-- Render text using explicit or automatically detected output policy. -/
def render (text : Text) (choice : ColorChoice := .auto) : IO String := do
  pure (Text.render (← target choice) text)

/-- Print text using explicit or automatically detected output policy. -/
def print (text : Text) (choice : ColorChoice := .auto) : IO Unit := do
  IO.print (← render text choice)

end TermColor
