# dotfiles

My shell, git, vim, [Zed](https://zed.dev), VS Code, [Cursor](https://cursor.com) and [Herdr](https://herdr.dev) settings for macOS (Apple Silicon). Copy whichever files or sections you like into your own config.

## What's inside

| Path                    | Goes to                                                   | What it does                                                                                                                                                                                                             |
| ----------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `.zshrc`                | `~/.zshrc`                                                | Oh My Zsh with the [Pure](https://github.com/sindresorhus/pure) prompt, history without duplicates, lazy-loaded nvm, colored `history`, an `rm` that moves files to the Bin, npm and port shortcuts, plus fzf and zoxide |
| `.zprofile`             | `~/.zprofile`                                             | Homebrew and Docker on `PATH`                                                                                                                                                                                            |
| `.gitconfig`            | `~/.gitconfig`                                            | Zed as the git editor; loads your identity from `~/.gitconfig.local`                                                                                                                                                     |
| `.vimrc`                | `~/.vimrc`                                                | Line numbers, cursor line, soft wrap, system clipboard                                                                                                                                                                   |
| `zed-settings.jsonc`    | `~/.config/zed/settings.json`                             | Vim mode, AI and telemetry off, quiet UI, Ayu Mirage theme                                                                                                                                                               |
| `vscode-settings.jsonc` | `~/Library/Application Support/Code/User/settings.json`   | Prettier on save, Dracula theme, a quiet writing layout for Markdown and MDX, screenshot paste into `images/`, Copilot in Markdown                                                                                       |
| `cursor-settings.jsonc` | `~/Library/Application Support/Cursor/User/settings.json` | The same editor and Markdown setup as VS Code, with Solarized Light, darker prose text and Cursor's agent settings                                                                                                       |
| `herdr-settings.jsonc`  | `~/.config/herdr-app/settings.json`                       | Google Sans Code at 15px with ligatures, no copy on select, always dark, agent sounds on, telemetry off (remove the comments when you copy it)                                                                            |
| `Brewfile`              |                                                           | The CLI tools `.zshrc` needs, plus my extras (commented out)                                                                                                                                                             |

`.zshrc`, `.vimrc` and the Zed, VS Code, Cursor and Herdr settings have a comment on every setting explaining what it does, so they're worth reading even if you don't copy them.

## Highlights

The bits of `.zshrc` most worth stealing. Each one stands alone, so you can paste it into your own `.zshrc`.

**nvm without the slow startup.** Loading nvm normally adds about 200ms to every new shell. Instead, `.zshrc` puts your default Node version on `PATH` straight away, so `node`, `npm`, `npx` and global tools work immediately, and only loads nvm the first time you type `nvm`. See the "Node.js (nvm, loaded lazily)" section.

**An `rm` you can undo.** In interactive shells, `rm` moves files to the Bin using macOS's built-in `trash` command (macOS 15+), so mistakes can be recovered. Habits like `rm -rf node_modules` still work: flags trash doesn't accept are dropped. Scripts still get the real `rm`, and `command rm` deletes permanently. See the "Safer rm" section.

**A colored, shorter `history`.** `history` shows the last 30 commands, colored like the syntax highlighting as you type: commands green, flags cyan, quoted text yellow, and `|`, `&&`, `;` magenta. `history 1` (or `hall`) shows everything. When piped, the output is plain and complete, so `history | grep foo` still searches all of it, and `hg foo` is a shortcut for that. Needs Oh My Zsh, because it wraps Oh My Zsh's `omz_history`. See the "History" section.

**No duplicate history entries.** Four `setopt` lines keep one copy of each command, so Up-arrow and Ctrl-R don't step through the same command over and over. See the "History" section.

**npm shortcuts.** `nr` (npm run), `nb` (build), `nd` (dev) and `ni` (install), plus `ncu` / `ncuu` to check for and apply dependency updates, and `ncui` to apply and install them in one go. `nfresh` deletes `node_modules` and `package-lock.json` and reinstalls. Tab completion still works, so `nr <Tab>` lists your scripts.

**Free up a port.** When a dev server won't start because "port already in use", `port 3000` shows what's listening there and `killport 3000` stops it. See the "Local dev servers" part of the "Aliases" section.

## Using these files

Open a file on GitHub and copy the parts you want into the matching file in your home folder (see the "Goes to" column above). Back up your own file first if you're replacing it wholesale.

The `.zshrc` expects [Homebrew](https://brew.sh), [Oh My Zsh](https://ohmyz.sh) and a few CLI tools. To install the tools:

```bash
brew bundle --file=Brewfile
```

If you use `.gitconfig` as is, add your identity:

```bash
git config --file ~/.gitconfig.local user.name  "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

## Local, private settings

These files are loaded if they exist, and they're never committed:

- `~/.zshrc.local`: API keys, tokens, machine-specific aliases
- `~/.gitconfig.local`: name, email, signing key

## Notes

- The `rm` override needs macOS 15 or later, for the built-in `trash` command. It only applies in interactive shells. Use `command rm` to delete permanently.
- The Zed config uses the [Google Sans Code](https://fonts.google.com/specimen/Google+Sans+Code) font and the Catppuccin icon theme extension. Install both, or change those lines.
- The VS Code and Cursor settings use the same font, plus these extensions: Prettier (`esbenp.prettier-vscode`), MDX (`unifiedjs.vscode-mdx`) and Code Spell Checker (`streetsidesoftware.code-spell-checker`). VS Code also uses Dracula Official (`dracula-theme.theme-dracula`).
- Herdr only reads plain JSON, so strip the comments from `herdr-settings.jsonc` before you paste it. If you don't, Herdr ignores the file and writes the reason to `~/.config/herdr-app/settings.error`. It uses Google Sans Code too.
- nvm is optional. Without it, the Node section does nothing.

## License

MIT
