# Vim/Neovim plugin details

The [README](../README.md) covers installation. These notes are for people changing the plugin or checking its behaviour.

## What the plugin recognises

- `.opensauce` file detection for new and existing files.
- Sections, ingredients/things, equipment declarations, actions, quantity/precision markers, operators, comments, products, parts/variants, results and explicit groups.
- `#` comment settings via `comments` and `commentstring`, while protecting URL fragments and Markdown images from accidental comment highlighting.
- `%` matching for parentheses, braces, square brackets and angle brackets.
- One-step indentation for explicit `[` groups, including Optional, Meanwhile and Repeat; existing continuation indentation is retained.
- Unindented `<<<` / `>>>` source fences, whose contents stay literal even when they resemble Sauce Code.

The plugin doesn't change fonts, colours, tabs/spaces, text width or key mappings. Its buffer-local options have undo hooks. Automatic wrapping and comment continuation are disabled in Sauce Code buffers. Highlighting is lexical: it doesn't validate recipes, know the meaning of every culinary term, or format source.

Unlike VS Code, this plugin does not add auto-closing brackets, surrounding pairs or a comment-toggle shortcut. Equipment is styled specially in its declaration section, but references elsewhere use generic thing styling. Long raw-source files may be slower because syntax synchronization starts at the beginning of the buffer.

## Test without installing

In Vim or Neovim, adjust the path and run:

```vim
:set runtimepath^=C:/path/to/vim-plugin
:filetype plugin indent on
:syntax enable
:runtime! ftdetect/opensauce.vim
:edit C:/path/to/vim-plugin/samples/example.opensauce
```

Check `:set filetype?`, `:set syntax?` and `:setlocal commentstring?` (expected `# %s`). To inspect the active highlight group under the cursor:

```vim
:echo synIDattr(synID(line('.'), col('.'), 1), 'name')
```

## Automated checks

From this repository:

```sh
vim -Nu NONE -n -es -S tests/run.vim
nvim --headless -u NONE -n -S tests/run.vim
```

The test log is written to ignored `tests/results.log`; assertions return a nonzero exit code on failure. The suite covers filetype detection, lexical scopes, comments, source isolation, malformed input, real insert-mode indentation, bracket matching and option restoration. It does not write to the recipe fixtures.

With `OSF_CORPUS` (or a sibling `../corpus` checkout), tests also inspect Ravioli, No-knead Bread and Cointreau Margarita. Without Corpus they run the standalone fixtures and report that the optional cases were skipped.

Vim 9.2 and Neovim 0.12.6 have recorded host-test evidence; Vim 8 is a compatibility target rather than a separately tested host. Autocomplete needs an LSP client and the separate [Sauce Code Language Server](https://github.com/TeblaDotNet/sauce-code-language-server); this plugin doesn't include either.
