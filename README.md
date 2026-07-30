# termcolor

[![CI](https://github.com/jonaprieto/lean-termcolor/actions/workflows/ci.yml/badge.svg)](https://github.com/jonaprieto/lean-termcolor/actions/workflows/ci.yml)
[![Lean 4](https://img.shields.io/badge/Lean%204-library-5f5f5f)](lean-toolchain)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)

ANSI colors and styled text for Lean 4.

`termcolor` keeps styled output as pure data. It supports the standard ANSI colors, bright
colors, the xterm 256-color palette, RGB colors, backgrounds, and common text attributes. IO is
limited to choosing a target for the current stdout and printing the rendered text.

## Install

Add the package to `lakefile.toml`:

```toml
[[require]]
name = "termcolor"
git = "https://github.com/jonaprieto/lean-termcolor"
rev = "main"
```

## Quick start

```lean
import TermColor

open TermColor
open scoped TermColor.Style

def message : Text :=
  Text.styled "ready" (Style.bold <+> Style.green)

#eval Text.render RenderTarget.ansi16 message

def main : IO Unit :=
  TermColor.print message
```

Use `Text.render` when the output target is known. Use `TermColor.print` when the library should
choose a target from the environment.

## API at a glance

- `Color.red`, `Color.brightBlue`, `Color.indexed 196`, `Color.rgb 255 127 0`, and
  `Color.default` describe colors independently of a terminal.
- `Style.bold <+> Style.red` composes SGR settings from left to right. Composition is associative,
  `Style.empty` is its identity, and the rightmost setting wins when settings overlap.
- `Text.styled "warning" Style.yellow ++ Text.plain "!"` preserves text order and style
  boundaries.
- `RenderTarget.plain`, `.ansi16`, `.ansi256`, and `.trueColor` make fallback behavior explicit.

RGB fallback uses the conventional xterm palette. A terminal may let users redefine that palette,
so exact RGB output requires `RenderTarget.trueColor`.

## Automatic output

`TermColor.print` is conservative: redirected output is plain by default, while active terminals
receive ANSI output. It respects the standard `NO_COLOR` and `FORCE_COLOR` conventions, and
`ColorChoice.always` and `.never` are explicit overrides.

Pass an explicit `RenderTarget` when the caller knows more about the destination than environment
detection can determine.

## Development

The executable library has no external runtime dependencies. The separate `Properties` package
keeps API properties out of the runtime library and does not require mathlib.

```sh
lake build TermColor Properties demo
lake exe demo
```

## License

Apache-2.0.
