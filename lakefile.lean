import Lake
open Lake DSL

package «termcolor» where
  version := v!"1.1.1"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

@[default_target]
lean_lib «TermColor» where
  -- Keep roots empty: a `TermColor` root would claim every satellite module
  -- (`TermColor.Layout`, `TermColor.Widgets`, and `TermColor.Terminal`).
  roots := #[]
  globs := #[.one `TermColor, .one `TermColor.Ansi, .one `TermColor.Color,
    .one `TermColor.ColorScheme, .one `TermColor.Detect, .one `TermColor.Style,
    .one `TermColor.Text]

lean_lib «TermColor.Properties» where
  globs := #[.andSubmodules `TermColor.Properties]

lean_exe «demo» where
  root := `Demo
  srcDir := "examples"
