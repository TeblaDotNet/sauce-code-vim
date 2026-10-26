# Sauce Code for Vim and Neovim

A small Vimscript plugin for editing `.opensauce` recipes. It adds syntax highlighting, file detection, comment settings, bracket matching and basic indentation.

**Related repositories:** [Sauce Code Core](https://github.com/TeblaDotNet/sauce-code) · [Language Server](https://github.com/TeblaDotNet/sauce-code-language-server) · [Recipes](https://github.com/TeblaDotNet/open-sauce-food-corpus) · [VS Code](https://github.com/TeblaDotNet/sauce-code-vscode)

## Install

Copy this repository's contents into a Vim/Neovim package folder named `opensauce`. The installed directory should contain `opensauce/ftdetect/opensauce.vim`.

**Vim 8+:** common package locations are:

- Linux/macOS: `~/.vim/pack/food/start/opensauce/`
- Windows: `~/vimfiles/pack/food/start/opensauce/`

Add these lines to your `vimrc` if they're not already enabled:

```vim
filetype plugin indent on
syntax enable
```

**Neovim:** run this inside Neovim to find a suitable package path:

```vim
:echo stdpath('data') . '/site/pack/food/start/opensauce'
```

Copy the plugin there and restart Neovim. A plugin manager also works if it adds the same runtime directory.

## Try it

Open a `.opensauce` file and run `:set filetype?`; it should report `opensauce`. Syntax colours follow your editor's theme. The plugin handles `#` comments, bracket matching with `%`, and indentation for explicit square-bracket groups.

For autocomplete, add the separate [Sauce Code Language Server](https://github.com/TeblaDotNet/sauce-code-language-server). Neovim 0.11.1+ can use its native LSP client; the language-server README includes a working configuration. Syntax highlighting works independently of the server.

## Contributing and tests

For syntax groups, raw-source fences, local options, testing and known limitations, see [plugin details](docs/syntax-and-testing.md). The runtime code and tests are MIT; documentation and sample encoding have their own terms. See [LICENSE](LICENSE) and [LICENSES](LICENSES/).
