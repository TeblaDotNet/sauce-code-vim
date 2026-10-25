# Sauce Code — Vim/Neovim support v1

Lightweight Sauce Code editing for `.opensauce` files. This is a Vim runtime
plugin: no Core installation, Node.js, language server or external plugin is
needed. It uses legacy Vimscript, intended for Vim 8+ and Neovim.

## Features

- Automatic filetype detection for existing and new `.opensauce` files.
- Theme-defined highlighting for sections, things, equipment declarations,
  actions, quantities and precision markers, operators, comments, product
  labels, variants/parts, results and explicit groups.
- `#` comments through `comments` and `commentstring`. Literal URL fragments
  and Markdown images are protected from comment highlighting.
- Standard `%` matching for parentheses, braces, square brackets and angle
  brackets. This does not insert closing brackets automatically.
- Basic indentation at explicit `[` group boundaries, including Optional,
  Meanwhile and Repeat. Existing continuation indentation is preserved.
- Unindented `<<<` / `>>>` fences under `::source` keep their contents literal,
  including apparent sections and comments.

The plugin respects your theme and indentation width. It does not set fonts,
colours, tabs versus spaces, text width or key mappings. Automatic text/comment
wrapping and automatic comment continuation are disabled in Sauce Code buffers.
Buffer-local options have undo hooks for filetype changes.

## Manual installation

Copy this entire directory into a native editor package directory named
`opensauce`. Do not copy just the repository's parent folder. The resulting
layout must include `opensauce/ftdetect/opensauce.vim`.

### Vim

For Vim 8 or newer, a usual location is:

- Linux/macOS: `~/.vim/pack/food/start/opensauce/`
- Windows: `~/vimfiles/pack/food/start/opensauce/`

Check `:set packpath?` if you use a custom configuration. Add these lines to
your vimrc if they are not already enabled:

```vim
filetype plugin indent on
syntax enable
```

### Neovim

Inside Neovim, run:

```vim
:echo stdpath('data') . '/site/pack/food/start/opensauce'
```

Copy this directory to the printed path. Restart Neovim and open a recipe.
Filetype plugins, indentation and syntax are normally enabled; if your setup
disables them, use the same two commands shown for Vim (or run them through
`vim.cmd` in init.lua). See the official
[Neovim package documentation](https://neovim.io/doc/user/pack/).

A plugin manager is optional: it only needs to add this runtime directory.
No dependency installation or build step is necessary.

### Try without installing

Start Vim or Neovim, then run (adjust the path):

```vim
:set runtimepath^=E:/Projects/open-sauce-food/vim-plugin
:filetype plugin indent on
:syntax enable
:runtime! ftdetect/opensauce.vim
:edit E:/Projects/open-sauce-food/vim-plugin/samples/example.opensauce
```

## Verify it is active

Run `:set filetype?` and `:set syntax?`; both should report `opensauce`.
Run `:setlocal commentstring?` to see `# %s`.
Place the cursor on a thing, action or quantity and run:

```vim
:echo synIDattr(synID(line('.'), col('.'), 1), 'name')
```

You should see an `opensauce...` syntax group. Theme colours may intentionally
be shared between several groups. You can customize the named groups using
your normal editor highlight configuration.

Set your preferred `shiftwidth`; entering a line after an explicit group
opener indents one step, and typing a standalone closing bracket aligns it with
its opener. Ordinary recipe lines retain authored indentation. This is not a
recipe formatter; it does not infer nesting from culinary meaning.

## Tests

From this repository, run either or both:

```sh
vim -Nu NONE -n -es -S tests/run.vim
nvim --headless -u NONE -n -S tests/run.vim
```

In PowerShell, prefix a quoted editor executable path with `&`.
A failing assertion produces a nonzero exit code; details and fixture count
are written to `tests/results.log` (ignored by Git).

Tests exercise filetype detection, semantic syntax groups, comments, products,
raw-source isolation, malformed-line recovery, actual insert-mode indentation,
standard bracket matching and option cleanup. They never write to recipes.

If a sibling `../corpus` checkout exists, tests also read Ravioli, No-knead Bread
and Cointreau Margarita. To require these fixtures from another checkout, set
`OSF_CORPUS` to its path. Without Corpus, standalone plugin tests still run;
the log explicitly records zero Corpus fixtures. No Core/Node dependencies are
used by the test suite.

Validation for v1: Git for Windows Vim 9.2, patches 1–858, with all three Corpus
fixtures. Neovim was not installed and has not been host-tested. Vim 8 is a
compatibility target, not a separately tested host.

## Language authority and limitations

Core's current [Sauce Code specification](../core/SPEC.md) is authoritative.
The sibling [VS Code extension v0.1.0](../vscode-extension/README.md) informed
the concept coverage. These local links assume the usual umbrella checkout;
neither repository is required to use this plugin.

This is syntax highlighting, not a second parser. It does not validate recipes,
resolve canonical vocabulary, distinguish local roles from canonical identities,
or provide diagnostics, completion, live preview, formatting, LSP or Tree-sitter.

Equipment is styled specially in `::equipment`; a thing referenced elsewhere
has generic thing styling, as in the VS Code grammar. Known quantity suffixes
are highlighted with numbers; arbitrary unit text remains ordinary text.
Story and notes are conservative prose contexts. Unknown section bodies use
ordinary Sauce Code highlighting.

Differences from VS Code: Vim highlight groups replace TextMate scopes;
raw-source payload uses Normal styling; no auto-closing quotes/brackets or
surround-selection commands are added. Comments are configured for native
editor commands and tools, without adding a comment-toggle mapping. Indentation
uses explicit group openers and respects existing continuation indentation.
Lexical highlighting may differ on malformed or unusually complex input.

Syntax synchronization starts at the beginning of the buffer so embedded
section-like lines in raw text stay safe. This favors correctness over speed
for very large retained source documents.

## Licensing

Runtime files and tests are MIT. This README and the authored sample encoding
are CC BY 4.0, following the project's split licensing approach.
The sample is adapted from Open Sauce Food VS Code extension v0.1.0,
copyright 2026 Tebla and Open Sauce Food contributors. See [LICENSE](LICENSE)
and [LICENSES](LICENSES/). No third-party recipes or brand assets are bundled.

## Project boundaries and contributions

Sauce Code is the language and tooling; Open Sauce Food is the culinary encyclopaedia and recipe collection built using it. Existing opensauce commands, filetype and extension identifiers remain unchanged. Knowledge is optional and is not loaded for editor completion. See the [seven-repository setup map](../core/docs/ecosystem.md), [contribution and AI-development disclosure](../core/CONTRIBUTING.md#development-process), and this repository's [licence scopes](LICENSE). Code review and culinary review are separate.

Optional completion uses a separate LSP client and server: see the [standalone Language Server and native Neovim configuration](../language-server/README.md). Neovim 0.11.1+ supports that configuration API; ordinary Vim needs a separately chosen LSP client. Standard Vim bracket matching and this plugin's syntax/comment/indent support do not depend on it. Existing host-validation records above are historical, not new validation claims.

Stage 6 documentation validation reran tests/run.vim in installed Neovim 0.12.6: passed, including three Corpus fixtures. Vim was not available on PATH for this pass; the earlier Vim validation remains historical evidence, not a new run.
