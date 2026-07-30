import Lake
open Lake DSL

package «termcolor» where
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

@[default_target]
lean_lib «TermColor» where
  globs := #[.andSubmodules `TermColor]

lean_lib «Properties» where
  globs := #[.andSubmodules `Properties]

lean_exe «demo» where
  root := `Demo
  srcDir := "examples"
