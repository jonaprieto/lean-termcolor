# Properties

Machine-checked statements about the `TermColor` API. This package is not built into the
runtime library and does not depend on mathlib, so a property may be added here without
adding weight or dependencies to anything a user imports.

Two files:

- [Basic.lean](Basic.lean) holds the algebraic laws: what composition, appending, and
  rendering are guaranteed to do for all inputs.
- [Examples.lean](Examples.lean) holds concrete lemmas that pin down the documented values
  (`rgbToAnsi256 255 0 0 = 196`, `sgr` of bold red at ANSI-16 is `\e[1;31m`). They double as
  the check that the README's claims stay true.

New properties are welcome. Prefer a law over an example when the law is provable, and keep
the statement in the vocabulary of the public API rather than of its implementation.

## Proven today

- `Style` is a monoid under `<+>` with `Style.empty` as identity: `style_empty_left`,
  `style_empty_right`, `style_combine_assoc`.
- Rendering distributes over appending: `render_append`, `concat_append`.
- The plain target erases styling exactly: `render_plain` says
  `Text.render .plain t = t.plainText`, so nothing but the visible text survives.
- `String.join` distributes over list append: `join_append`, the workhorse behind the
  rendering laws.

## Worth proving next

Roughly in order of how much they buy relative to their proof cost.

**Text is a monoid.** `Text.empty ++ t = t`, `t ++ Text.empty = t`, and associativity of
`Text.append`. The `Style` side is done; the `Text` side is the same three-line argument over
`List.append` and completes the pair.

**`plainText` is a monoid homomorphism.** `plainText (l ++ r) = plainText l ++ plainText r`,
plus `plainText Text.empty = ""`. It follows from `join_append`, and it is the statement that
appending styled text never changes what the reader sees.

**Empty segments are invisible.** `Style.wrap target style "" = ""` already holds by
definition; lifting it to `Text` gives that dropping empty segments does not change
`Text.render` at any target. This is the normalization law a future builder representation
would need.

**`perChar` and `rainbow` preserve the text.** `plainText (Text.perChar s f) = s`, hence
`plainText (Text.rainbow s) = s`. Per-character styling splits a string into single-character
segments, so this is the guarantee that the split and rejoin are lossless.

**Color indices stay in range.** `Color.rgbToAnsi256 r g b ≥ 16` (an RGB approximation never
silently lands on an ANSI-16 slot) and `Color.rgbToAnsi16 r g b < 16`. Both are arithmetic
facts about `channel6` and the `nearestAnsi16` loop, not `decide` targets, since the RGB
domain has 2^24 points.

**Basic colors are level-invariant.** For every level other than `.none`,
`Color.sgrCodes layer level (.ansi i c)` produces the same codes. Downgrading a target never
degrades a color that the basic palette can already express exactly; the same holds for
`toAnsi256 (.indexed i) = some i`.

**`hue` has period 360.** `Color.hue (d + 360) = Color.hue d`, and `hue d` is always `.rgb`.
The wheel is defined on all of `Nat` by construction, so this states the construction is what
it looks like.

**`sgr` is well-formed.** Every nonempty result of `Style.sgr` starts with `ESC [` and ends
with `m`, and its interior is digits and semicolons only. This is the statement that the
encoder cannot emit a sequence that means something other than SGR.

## Not claimed

Two limits are deliberate, and a property should not pretend otherwise.

Segment text is emitted verbatim. If a caller puts an escape sequence inside a `Segment`, it
reaches the terminal. `Text.render` is not a sanitizer.

`Style.wrap` closes with a full reset (`ESC [0m`), not with the inverse of the style it
opened. Nested rendering therefore clears an enclosing style at the inner segment's end. The
segment list is flat, so this never arises from the API itself, but it rules out a naive
"rendering composes under nesting" law.
