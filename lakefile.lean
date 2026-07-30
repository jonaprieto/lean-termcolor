import Lake
open Lake DSL

package «termcolor» where
  version := v!"1.0.0"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

-- API documentation is opt-in so normal users keep the zero-dependency core.
meta if get_config? env = some "dev" then
  require «doc-gen4» from git
    "https://github.com/leanprover/doc-gen4" @ "a41d5ebebfa77afe737fec8de8ad03fc8b08fdff"

@[default_target]
lean_lib «TermColor» where
  globs := #[.andSubmodules `TermColor]

lean_lib «Properties» where
  globs := #[.andSubmodules `Properties]

lean_exe «demo» where
  root := `Demo
  srcDir := "examples"
