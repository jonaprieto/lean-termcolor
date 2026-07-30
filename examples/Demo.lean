import TermColor

open TermColor
open scoped TermColor.Style

def main : IO Unit := do
  let hello := Text.styled "hello" (Style.bold <+> Style.cyan)
  let world := Text.styled " world" Style.underline
  TermColor.print (hello ++ world)
