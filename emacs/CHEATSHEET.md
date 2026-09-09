# C# and Mojo development in Emacs — macOS cheatsheet

**C = Control · M = Command · RET = Return · SPC = Space**

Evil is enabled. You start in Normal state; `i` enters Insert, `v` enters
Visual, and `Esc` returns to Normal. Standard Vim operators, motions, text
objects, registers, marks, macros, `/` and `?` search, `.` repeat, `ciw`,
`da(`, `f`, `t`, `%`, and `:`, work as they do in Neovim. `SPC` is your leader.

`C-c l r r` means Control-c, release, then `l`, `r`, `r`.
`C-M-=` means hold Control and Command together and press `=`.
Option remains available for typing symbols. These are your configured bindings;
Control-Command-arrow window navigation has not been added.

## Learn these first

| Keys | Action |
| --- | --- |
| `C-g` | Cancel the current command, prompt, or selection |
| `M-x` | Run any command by name |
| `C-x C-f` | Open a file |
| `C-x C-s` | Save this file |
| `C-x o` | Switch to the next window/pane |
| `C-x b` | Switch buffer (file or tool output) |
| `C-=` | Expand selection outward |
| `M-.` / `M-,` | Definition / return to previous location |
| `C-c l a a` | Code actions and fixes |
| `C-c n b` | Build |
| `M-g n` / `M-g p` | Next / previous build diagnostic |

## Files, buffers, and projects

| Keys | Action |
| --- | --- |
| `C-x C-f` | Find/open file; enter a new name to create one |
| `C-x C-s` | Save buffer |
| `C-x s` | Offer to save all modified file buffers |
| `C-x C-w` | Save as another filename |
| `C-x b` | Switch buffer |
| `C-c b` | Search buffers and recent files with Consult |
| `C-x k` | Close a buffer (prompts to save changes) |
| `C-x C-b` | List buffers |
| `C-x p p` | Switch project |
| `C-x p f` | Find a file in the project |
| `C-c s` | Search project contents with ripgrep |
| `C-c i` | Jump to a symbol in this file |
| `C-c e` | Open/focus Treemacs file tree |
| `C-x d` | Open a directory in Dired |

In completion prompts, type space-separated fragments to narrow matches.
Use `C-n`/`C-p` or arrows to select and Return to accept. `C-g` cancels.

## Windows (panes)

A buffer holds a file or tool output; a window displays a buffer.

| Keys | Action |
| --- | --- |
| `C-x o` | Next window; toggles when there are two |
| `C-x 2` | Split into top/bottom windows |
| `C-x 3` | Split into left/right windows |
| `C-x 0` | Close this window; its buffer stays open |
| `C-x 1` | Keep only this window; other buffers stay open |
| `C-x +` | Balance window sizes |
| `C-c <left>` / `C-c <right>` | Undo / redo window layout changes (Winner) |
| `C-h` / `C-j` / `C-k` / `C-l` | Evil Normal: move left/down/up/right between panes |
| `C-\\` | Evil Normal: move to previous/next pane |

Build output normally appears without taking focus from your code.
Use `C-x o` to visit it, or jump straight to a diagnostic with `M-g n`.

## Editing and selecting

| Keys | Action |
| --- | --- |
| `C-=` | Expand selection: word → expression → enclosing context |
| `C-M-=` | Shrink selection |
| `C-SPC`, then move | Set mark and select text |
| `C-x h` | Select the entire buffer |
| `M-w` | Copy selection |
| `C-w` | Cut selection |
| `C-y` | Paste (yank) |
| `M-y` after `C-y` | Cycle through earlier copied/killed text |
| `C-/` | Undo |
| `C-k` | Cut to end of line; again to remove newline |
| `M-d` / `M-DEL` | Cut next / previous word (DEL = Backspace) |
| `M-;` | Comment/uncomment selection, or work with a line comment |
| `TAB` | Indent; context may instead expand a snippet/completion |
| `C-M-\\` | Indent selected region |

If macOS intercepts Control-Space for input switching, `C-@` also sets the mark,
or use `M-x set-mark-command`.

## Moving and searching

| Keys | Action |
| --- | --- |
| `C-a` / `C-e` | Start / end of line |
| `M-b` / `M-f` | Previous / next word |
| `C-M-b` / `C-M-f` | Backward / forward across an expression |
| `M-<` / `M->` | Start / end of buffer |
| `C-v` / `M-v` | Scroll down / up a page |
| `C-l` | Recenter; repeated presses cycle center/top/bottom |
| `C-s` / `C-r` | Incremental search forward / backward |
| `C-s` again during search | Next match |
| `RET` during search | Finish search at the match |
| `M-%` | Query replace; `y` replace, `n` skip, `!` replace remaining, `q` quit |
| `M-g g` | Go to line number |

## Autocomplete and snippets

Type a name or `Console.` and pause for completion suggestions.

| Keys | Context / action |
| --- | --- |
| `C-M-i` | Request completion manually |
| `M-x company-complete` | Alternative manual completion command |
| `C-n` / `C-p`, or arrows | Select next / previous dropdown candidate |
| `RET` | Accept selected dropdown candidate |
| `TAB` | In dropdown: complete common prefix or cycle candidates |
| `M-h` | In dropdown: documentation for selected candidate |
| `C-g` | Dismiss dropdown |
| `M-x yas-insert-snippet` | Choose a snippet |
| `TAB` / `S-TAB` | In an active snippet: next / previous field |

## LSP navigation, refactoring, and live diagnostics (C# only)

Place the cursor on the symbol you want to act on. For some refactorings,
select the expression or statements first.

| Keys | Action |
| --- | --- |
| `M-.` | Go to definition |
| `M-,` | Return from navigation |
| `M-?` | Find references/usages |
| `C-c l g i` | Find implementations |
| `C-c l g t` | Find type definition |
| `C-c l h h` | Show documentation/type at cursor |
| `C-c l h s` | Show function signature help |
| `C-c l r r` | Rename symbol across the project |
| `C-c l a a` | Available fixes and refactorings |
| `C-c l = =` | Format file |
| `C-c l = r` | Format selected region (or current line) |
| `C-c ! n` / `C-c ! p` | Next / previous live diagnostic (Flycheck) |
| `C-c ! l` | List live diagnostics |
| `C-c l w r` | Restart language server |
| `C-c l w d` | Describe LSP session |
| `gd` / `gD` / `gr` | Evil Normal: definition / declaration / references |
| `K` | Evil Normal: hover documentation |
| `SPC d` | Evil Normal: diagnostic at cursor |

Pause after `C-c l` to see the which-key command menu.
Errors have red wavy underlines; warnings yellow waves; Roslyn information and
suggestions subtle gray underlines. Pause on an underline for its message at
the bottom. Optional refactorings do not create markers. Mojo uses tree-sitter
highlighting without LSP or live diagnostics: build with `SPC m m`, navigate
compiler errors with `]q` / `[q`, and format with `SPC m f` (`mojo format`).

## Build, test, and run

The keys follow the language of the current buffer: `dotnet` in C# buffers,
`mojo` in Mojo buffers. Output buffers reuse the last toolchain used.

| Keys | Action |
| --- | --- |
| `C-c n b` | Run editable build command (`dotnet build` / `mojo build FILE`) |
| `C-c n t` | Run editable test command (`dotnet test` / `mojo run test_FILE`) |
| `C-c n r` | Run editable run command (`dotnet run` / `mojo run FILE`) |
| `M-x recompile` | Repeat previous compilation command |
| `M-g n` / `M-g p` | Next / previous build error or warning |
| Ctrl-x, then backtick | Another binding for next build diagnostic |
| `RET` on a diagnostic in build output | Visit source location |
| `g` in compilation buffer | Repeat the command |
| `C-c C-k` in compilation buffer | Stop the running build/process |
| `M-x eshell` | Open Emacs shell |

C# commands start in the closest `.csproj` directory. Edit the command before
Return to target a solution, add test filters, or pass arguments. For example:
`dotnet build /path/to/App.slnx` or `dotnet test --filter FullyQualifiedName~MyTest`.
Mojo commands start in the closest pixi/pyproject directory and name the
current file; `mojo build` writes the executable there. Mojo tests are
TestSuite programs, so `C-c n t` runs the current `test_*.mojo` file, or asks
for one. Use Eshell or a terminal for programs requiring interactive input.

**Fix loop:** `C-c n b` → Return → `M-g n` → edit → `C-x C-s` →
`M-x recompile` → Return. Live Flycheck diagnostics (`C-c ! n`) and compiler
output diagnostics (`M-g n`) are separate lists.

## Neovim-compatible leader map

| Keys | Action |
| --- | --- |
| `SPC e` | File tree |
| `SPC p f` / `SPC p s` / `SPC p b` / `SPC p h` | Project file / project search / buffers / help search |
| `SPC m m` / `SPC m t` / `SPC m r` | Build / test / run with the buffer's toolchain |
| `SPC m c` | C#: build without restore. Mojo: build with debug info for the debugger |
| `SPC m f` | Format: LSP in C#, `mojo format` in Mojo |
| `SPC c o` / `SPC c c` | Open compilation output / close its window |
| `]q` / `[q` | Next / previous compilation diagnostic |
| `SPC s v` / `SPC s h` / `SPC s e` / `SPC s x` | Split right / below / balance / close pane |
| `SPC d d` | Toggle 130-column focused view |
| `SPC d m` / `SPC d l` | Widen / narrow focused view |

`SPC d` overlaps with the focus commands in your Neovim setup. Emacs waits
0.4 seconds: press `d`, `m`, or `l` immediately after it for the focus command;
otherwise it shows the diagnostic. `C-d`, `C-u`, `n`, and `N` recenter the cursor after moving, matching your
Neovim setup. In Visual state, `J` and `K` move the selected lines down/up.

## Debugging (netcoredbg for C#, mojo-lldb-dap for Mojo)

C#: build Debug first, set a breakpoint on executable code, then select your
application DLL under `bin/Debug/<framework>/`. Keep the `.pdb` beside it.
Mojo: build with `SPC m c`, set a breakpoint, then select the executable in the
project directory. In the Mojo debug console, plain input evaluates a Mojo
expression and a leading `:` runs an LLDB command (`:thread list`).

| Keys | Action |
| --- | --- |
| `C-c d b` | Toggle breakpoint |
| `C-c d d` | Launch the built DLL (C#) or executable (Mojo) under the debugger |
| `C-c d a` | Attach to a running process by PID |
| `C-c d h` | Open debugger control menu |

The following keys apply **after opening `C-c d h`**:

| Keys | Action |
| --- | --- |
| `n` / `i` / `o` | Step over / into / out |
| `c` | Continue |
| `s l` | Show locals |
| `s f` | Choose stack frame |
| `s b` | List breakpoints |
| `b c` | Set breakpoint condition |
| `e e` | Evaluate an expression |
| `e s` | Evaluate thing at cursor |
| `e a` | Add watch expression |
| `d l` | Debug last configuration |
| `q` | Close control menu; leave debugging active |
| `Q` | Disconnect debugger |

## Git with Magit

| Keys | Context / action |
| --- | --- |
| `C-c g` | Open Magit status |
| `TAB` | In status: expand/collapse section or diff |
| `s` / `u` | In status: stage / unstage file or hunk at cursor |
| `c c` | In status: create commit |
| `C-c C-c` | In commit-message buffer: finish commit |
| `C-c C-k` | In commit-message buffer: cancel commit editing |
| `g` / `q` | In status: refresh / quit window |
| `?` | In Magit: show available commands |

Staging a selected diff region stages that part. Review the staged diff before
committing. Push/pull menus are available through Magit's `?` menu.

## Help and recovery

| Keys | Action |
| --- | --- |
| `C-g` | Cancel/get out |
| `C-h k`, then a key sequence | Explain what those keys do here |
| `C-h m` | Describe active modes and their keybindings |
| `C-h f` | Documentation for a command/function |
| `C-h t` | Built-in Emacs tutorial |
| `C-h b` | List currently available keybindings |
| `M-x recover-file` | Recover an auto-saved file after a crash |

Bindings are context-sensitive: Return accepts completion when a dropdown is
open, but visits an error when point is on a compilation diagnostic. `C-h k`
helps resolve surprises.
