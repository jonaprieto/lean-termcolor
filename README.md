# termcolor

[![CI](https://github.com/jonaprieto/lean-termcolor/actions/workflows/ci.yml/badge.svg)](https://github.com/jonaprieto/lean-termcolor/actions/workflows/ci.yml)
[![Lean 4](https://img.shields.io/badge/Lean%204-library-5f5f5f)](lean-toolchain)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)

ANSI colors and styled text for Lean 4. `Text` is pure data; terminal IO is provided by the
optional detection and terminal packages.

Version: `v1.1.0`

## Install

```lean
require termcolor from git
  "https://github.com/jonaprieto/lean-termcolor.git" @ "v1.1.0"
```

## Quick start

```lean
import TermColor
import TermColor.Detect

open TermColor
open scoped TermColor.Style

def message : Text := Text.styled "ready" (Style.bold <+> Style.green)

#eval Text.render RenderTarget.plain message
#eval Text.render RenderTarget.ansi16 message
```

`Color`, `Style`, `ColorScheme`, `Text.render`, and OSC-8 hyperlinks are pure. `TermColor.Detect`
selects a target from terminal capabilities, `NO_COLOR`, `FORCE_COLOR`, and `TERM`.

## Build

```sh
lake build TermColor TermColor.Properties demo
lake exe demo
```

## Related projects

[`termcolor-layout`](https://github.com/jonaprieto/lean-termcolor-layout) provides layout;
[`termcolor-widgets`](https://github.com/jonaprieto/lean-termcolor-widgets) provides pure views;
[`termcolor-terminal`](https://github.com/jonaprieto/lean-termcolor-terminal) provides terminal IO.

## License

Apache-2.0.
