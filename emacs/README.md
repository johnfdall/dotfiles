# Emacs for C# and Mojo on macOS

See [CHEATSHEET.md](CHEATSHEET.md) for the development keybindings and common workflows.

Emacs 31.1 with native compilation, JetBrains Mono 14 pt, and the built-in dark
Modus Vivendi theme. Evil mode supplies Vim-style Normal, Insert, Visual, and
Ex states, plus your Neovim leader and window bindings; see
[CHEATSHEET.md](CHEATSHEET.md). Command is Meta (`M`); Control remains Control
(`C`); Option types normal macOS characters. For example, `M-x` means Command-x.
`C-x C-f` means Control-x then Control-f. `C-g` cancels a command and `C-h t`
opens the built-in tutorial.

## Installed configuration

`~/.emacs.d` links to this package's `.emacs.d`. The previous configuration is
preserved in `legacy-emacs.el` and is not loaded. Runtime state and downloaded
packages live in the ignored `.emacs.d/var/` directory.

The unmodified `early-init.el` and `init.el` come from
[minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d), commit
`9ef100c6e8e187de2a385bf2304437100f2b06e2`. Its license is included as
`LICENSE.minimal-emacs`. Customize `pre-early-init.el`, `post-init.el`, or
the files under `lisp/`; keep the upstream files unchanged when updating.

Roslyn runs through the existing `~/.dotnet/tools/roslyn-language-server`
(5.11.0-1.26381.12, .NET 10). The small lsp-mode client uses its modern stdio
transport and opens `.sln`, `.slnx`, or a standalone `.csproj`. When multiple
solutions are present, choose one at the prompt. Open a `.cs` file inside your
project and accept the project root if lsp-mode asks. Restore/build the project
so Roslyn can resolve its dependencies. Tree-sitter supplies syntax highlighting;
Roslyn supplies completion, diagnostics, hover documentation, navigation,
rename, code actions, and semantic highlighting.

Mojo 1.0 comes from pixi (`pixi global install mojo`), which places `mojo`,
`mojo-lsp-server`, and the `mojo-lldb-dap` debug adapter in `~/.pixi/bin`;
the configuration adds that directory to Emacs's PATH. `.mojo` and `.🔥` files
open in `mojo-ts-mode` (`lisp/mojo-ts-mode.el`), a tree-sitter mode built on
the community [tree-sitter-mojo](https://github.com/dmitry-salin/tree-sitter-mojo)
grammar pinned to v1.0.5. It borrows Python's indentation engine, taught about
`struct`, `trait`, and `comptime if` blocks, because the grammar is Python's
with Mojo additions. Mojo uses tree-sitter highlighting without LSP or live
diagnostics. Build with `SPC m m` and navigate compiler errors with `]q` / `[q`.
`SPC m f` runs `mojo format` on the file.
Language wiring lives in `lisp/dotfiles-mojo.el`.

Diagnostics use red wavy underlines for errors, yellow wavy underlines for
warnings, and subtle gray underlines for information/suggestions reported by
Roslyn. The fringe also marks diagnostic lines. Pause on an underline to read
the message in the echo area; `C-c ! n` / `C-c ! p` move between diagnostics.
Use `C-c l a a` for fixes or optional refactorings. Available code actions alone
do not create a marker, and long diagnostic/action labels are hidden.

## Everyday commands

| Keys | Action |
| --- | --- |
| `C-x C-f` / `C-x C-s` | Open / save file |
| `C-x b` / `C-x k` | Switch / kill buffer |
| `C-x p f` / `C-x p p` | Find project file / switch project |
| `C-x 2`, `C-x 3`, `C-x 1`, `C-x o` | Split below, split right, one window, other window |
| `C-/` | Undo |
| `C-=` / `C-M-=` | Expand selection / shrink selection (Control-= / Control-Command-=) |
| `M-.` / `M-,` / `M-?` | Definition / return / references |
| `C-M-i` | Complete at point (completion also appears automatically) |
| `C-c l` | LSP command menu, with which-key hints |
| `C-c l r r` | Rename symbol |
| `C-c l a a` | Code actions |
| `C-c l = =` | Format buffer |
| `C-c s` / `C-c i` | Project text search / buffer symbol search |
| `C-c g` / `C-c e` | Magit Git interface / file tree |
| `C-c n b` / `C-c n t` / `C-c n r` | Build / test / run with the buffer's toolchain |
| `C-x backtick` | Next compiler error |
| `M-x flycheck-list-errors` | Diagnostics list |
| `M-x eshell` | Emacs shell |

Build/test/run commands pick the toolchain from the current buffer's language
(`lisp/dotfiles-build.el`) and let you edit the command before running it.
Output buffers such as compilation or Magit reuse the toolchain of the last
buffer that ran a command. In C#, commands start in the closest project; add a
solution path to build or test an entire solution, or `--filter` to select
tests. In Mojo, commands start in the closest pixi/pyproject directory and act
on the current file: `mojo build`, `mojo run`, and, for tests, `mojo run` on a
`test_*.mojo` TestSuite program (Mojo 1.0 removed `mojo test`). Use
`M-x compile` for other commands. `M-x recompile` repeats the previous command.
These commands use compilation buffers; use Eshell or a terminal for programs
requiring interactive input.

## Debugging

`C-c d d` launches, and `C-c d a` attaches, with the debugger for the current
buffer's language.

### C#

1. Build with `C-c n b` (`dotnet build`, Debug configuration).
2. Set a breakpoint on an executable line with `C-c d b`.
3. Press `C-c d d` and select your application's DLL under
   `bin/Debug/<framework>/`. Keep its portable `.pdb` alongside it.
4. Use `C-c d h` for the debugger control menu (continue, step, inspect, quit).
   DAP opens locals, sessions, and breakpoint views automatically.

`C-c d a` attaches to a running .NET process by PID. `M-x dap-debug` also offers
templates and project `.vscode/launch.json` configurations. For projects needing
arguments or environment variables, use a `coreclr` launch configuration with
explicit `program`, `cwd`, `args`, and `env`. The simple DLL picker uses the
nearest project as its working directory and the internal debug console.

[Samsung netcoredbg](https://github.com/Samsung/netcoredbg) release
`3.2.0-1092` (macOS arm64) is installed under
`~/.local/share/netcoredbg/3.2.0-1092/`; `~/.local/bin/netcoredbg` is a wrapper
that preserves the real binary location for adjacent-library discovery.
Do not replace that wrapper with a binary symlink. Upstream describes macOS
arm64 as community supported; this setup was smoke-tested against .NET 10.

### Mojo

1. Build with debug info using `SPC m c` (`mojo build --debug-level full
   --no-optimization`), which writes the executable into the project directory.
2. Set a breakpoint with `C-c d b`.
3. Press `C-c d d` and select the executable; `C-c d h` opens the same
   control menu as for C#.

The adapter is `mojo-lldb-dap` from the Mojo package, run the way the Mojo VS
Code extension runs it: it loads `libMojoLLDB.dylib` from the pixi environment
so LLDB understands Mojo types, and the debug console treats a leading `:` as
an LLDB command. The bundled LLDB has no Python scripting, so its data
formatters print a harmless import error at startup. pixi's `debugserver` is
ad-hoc signed, so on the first launch macOS asks for your password to grant
Developer Tools access; `sudo DevToolsSecurity -enable` makes that permanent.
Without it the launch fails with "Not allowed to attach to process", which is
also why the scripted check during setup could only verify the adapter start,
breakpoint request, and target creation, not a stop at a breakpoint.

## Reinstall and update

On an Apple Silicon Mac with Homebrew and a .NET 10 SDK:

```sh
brew bundle --file=emacs/Brewfile
# Only if the Roslyn tool is not already installed:
dotnet tool install --global roslyn-language-server --version 5.11.0-1.26381.12
sh emacs/scripts/install-local.sh
open -a Emacs
```

The installer refuses to overwrite another Emacs configuration and verifies
the pinned debugger archive's SHA-256. It installs Mojo through pixi when
`~/.pixi/bin/mojo` is missing (tested with Mojo 1.0.0); `pixi global update
mojo` upgrades it later, and `pixi global list` shows the installed version.
Emacs packages are installed from GNU ELPA, NonGNU ELPA, and MELPA; they are
not version-locked. The C# grammar is pinned to v0.23.1 and the Mojo grammar
to v1.0.5. Use `M-x list-packages` to review package updates, and
`brew upgrade --cask emacs-app font-jetbrains-mono` for the application/fonts.
Update the Roslyn global tool deliberately because Neovim shares it.

For startup diagnostics, run `emacs --debug-init`. For LSP diagnostics use
`M-x lsp-describe-session`; the server's stderr buffer contains process errors.
The installed Roslyn version returned exit code 134 during an explicit batch
shutdown test, although solution loading, hover, and completion worked in both
batch and GUI checks. If a server exits during editing, use `M-x lsp-workspace-restart`.
