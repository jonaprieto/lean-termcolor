# termcolor

Proof-friendly terminal colors and text styles for Lean 4.

`termcolor` models the parts of ANSI Select Graphic Rendition that are useful for command-line
programs: the eight standard colors, bright colors, the xterm 256-color palette, RGB colors,
backgrounds, and common text attributes. Styled text is pure data. Rendering is pure too; IO is
only used when the library chooses a target for the current stdout.

The package has no dependencies outside Lean's standard library.

## A small example

```lean
import TermColor

open TermColor
open scoped TermColor.Style

def message : Text :=
  Text.styled "ready" (Style.bold <+> Style.green)

#eval Text.render RenderTarget.ansi16 message
#eval Text.render RenderTarget.plain message

def main : IO Unit :=
  TermColor.print message
```

`TermColor.print` uses a conservative automatic policy. Use `TermColor.print message .always`
when a command-line option explicitly asks for ANSI output, or render directly with
`RenderTarget.ansi16`, `RenderTarget.ansi256`, `RenderTarget.trueColor`, or `RenderTarget.plain`.

## The model

There are three separate ideas:

- `Color` is terminal-independent data: `Color.red`, `Color.brightBlue`,
  `Color.indexed 196`, `Color.rgb 255 127 0`, and `Color.default`.
- `Style` is a sequence of SGR settings. `Style.bold <+> Style.red` means “apply bold, then
  red”. The operator is associative, has `Style.empty` as its identity, and is intentionally
  not commutative: for overlapping settings the rightmost one wins.
- `Text` is an ordered list of segments. `Text.styled "warning" Style.yellow ++ Text.plain "!"`
  preserves the style boundary and the visible text order.

An explicit `RenderTarget` controls degradation:

| target | emitted colors |
| --- | --- |
| `plain` | no ANSI sequences |
| `ansi16` | the eight standard colors and their bright variants |
| `ansi256` | the xterm 256-color palette |
| `trueColor` | 24-bit RGB, plus ANSI and indexed colors |

RGB fallback uses the conventional xterm palette. Since terminals may let users redefine their
palette, RGB-to-ANSI fallback is an approximation; code that needs exact RGB should request
`RenderTarget.trueColor`.

## Automatic output policy

`TermColor.target` and `TermColor.print` use the process environment and Lean's portable `isTty`
operation:

1. `ColorChoice.never` always produces plain output.
2. A non-empty `NO_COLOR` suppresses colors. It does not suppress non-color attributes when
   stdout is an active terminal.
3. A non-empty `FORCE_COLOR`, or `ColorChoice.always`, enables ANSI output even when stdout is
   redirected.
4. `TERM=dumb` and `TERM=unknown` disable automatic ANSI output.
5. A TTY receives ANSI output; redirected output is plain by default.

`COLORTERM=truecolor`/`24bit` selects true color. A `TERM` ending in `-256color` selects the
256-color palette. Detection is deliberately conservative and can never know how a terminal has
reconfigured its palette, so callers with stronger knowledge should pass an explicit target.

## Proofs

The executable library is kept separate from `Properties`, which currently proves:

- style identity and associativity;
- concatenation of the text renderer;
- plain rendering preserves the underlying text.

These are Lean theorems, not runtime tests. `Properties` imports only `TermColor`; mathlib is not
needed.

Build both the library and its theorem package with:

```sh
lake build TermColor Properties demo
```

Run the sample executable with:

```sh
lake exe demo
```

## Why this shape?

The data types follow a useful common ground in existing terminal libraries. Haskell's
`ansi-terminal` separates SGR constructors such as intensity, underlining, layers, basic colors,
palette indices, and RGB. OCaml's `ansifmt` treats a style as an associative, non-commutative
composition. Rich's `Style` uses tri-state attributes and its `Text` stores styled spans. Here,
the same semantics are represented by a small list of typed settings, which keeps composition
transparent to both humans and proofs.

References: [Rich](https://github.com/Textualize/rich),
[termcolor-c](https://github.com/ararslan/termcolor-c),
[ansi-terminal types](https://hackage.haskell.org/package/ansi-terminal-0.9.1/docs/System-Console-ANSI-Types.html),
[OCaml ansifmt](https://ocaml.org/p/ansifmt/latest/doc/ansifmt/Ansifmt/Ansi/index.html),
[POSIX terminfo](https://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html),
[NO_COLOR](https://no-color.org/), and [FORCE_COLOR](https://force-color.org/).

## License

Apache-2.0.
