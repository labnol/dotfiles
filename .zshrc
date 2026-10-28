# ~/.zshrc: zsh config for macOS (Apple Silicon) using Oh My Zsh.
#
# Requirements:
#   - Oh My Zsh   https://ohmyz.sh
#   - Homebrew    https://brew.sh (~/.zprofile runs `brew shellenv`, which sets $HOMEBREW_PREFIX)
#   - brew install pure fzf zoxide zsh-syntax-highlighting
#   - nvm         https://github.com/nvm-sh/nvm (optional)
#   - macOS 15+ for the built-in `trash` command used by rm below

# ----------------------------------------------------------------------------
# Oh My Zsh
# ----------------------------------------------------------------------------

# Where Oh My Zsh is installed.
export ZSH="$HOME/.oh-my-zsh"

# Empty theme: the prompt comes from Pure (set up below), so don't load an
# Oh My Zsh theme only to replace it.
ZSH_THEME=""

# Plugins bundled with Oh My Zsh:
#   git                  aliases such as gst (git status), gco (git checkout), gp (git push)
#   npm                  tab completion for `npm run <script>`, plus npm aliases (npmO, npmL0, ...)
#   zsh-autosuggestions  suggests the rest of a command from history in grey; press → to accept
plugins=(git npm zsh-autosuggestions)

# Let zsh find Homebrew's completion scripts and the Pure prompt.
# This has to run before Oh My Zsh is loaded, because that's when completions
# are set up. Falls back to /opt/homebrew if $HOMEBREW_PREFIX isn't set.
fpath+=("${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions")

# Load Oh My Zsh with the settings above.
source $ZSH/oh-my-zsh.sh

# ----------------------------------------------------------------------------
# History
# ----------------------------------------------------------------------------

# Keep one copy of each command. Oh My Zsh only skips a command that repeats
# the one right before it; these drop duplicates anywhere in history.
setopt hist_ignore_all_dups  # running a command again removes its older copy
setopt hist_save_no_dups     # never write duplicates to ~/.zsh_history
setopt hist_find_no_dups     # Up-arrow and Ctrl-R skip repeats
setopt hist_reduce_blanks    # "ls   -la" is saved as "ls -la"

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------

# Pure: a minimal prompt that shows the folder, git branch and status, and how
# long slow commands took. https://github.com/sindresorhus/pure
autoload -U promptinit; promptinit
prompt pure

# ----------------------------------------------------------------------------
# Node.js (nvm, loaded lazily)
# ----------------------------------------------------------------------------

# Loading nvm.sh takes ~200ms, which used to be most of shell startup. Instead,
# put the default Node version on PATH right away (so node, npm, npx and
# global npm tools work), and only load nvm the first time `nvm` is run.
export NVM_DIR="$HOME/.nvm"

# Find the newest installed Node matching nvm's default alias (e.g. "24" ->
# v24.22.0) and add its bin folder to the front of PATH. Runs once, at startup.
() {
  local default_node=( $NVM_DIR/versions/node/v${$(<$NVM_DIR/alias/default 2>/dev/null)#v}*(N/nOn[1]) )
  [[ -n $default_node ]] && path=("$default_node/bin" $path)
}

# Placeholder `nvm`: on first use it removes itself, loads the real nvm and its
# tab completion, then passes the command through.
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# ----------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------

# npm shortcuts. Tab completion still works, e.g. `nr <Tab>` lists scripts.
alias nr="npm run"
alias nb="npm run build"
alias nd="npm run dev"
alias ni="npm install"

# Check for newer versions of dependencies (ncu), or update package.json to
# them (ncuu); run `ni` afterwards to install.
alias ncu="npx npm-check-updates"
alias ncuu="npx npm-check-updates -u"

# In the terminal, `history` shows the last 30 commands (`history 1` shows
# all, `history -100` the last 100), colored to match the typing highlights:
# line numbers dim, commands green, flags cyan, quoted text yellow, and
# | && || ; magenta. Uses the terminal's own palette, so it works with light
# and dark themes. When the output goes to a pipe or file it's plain and
# complete, so `history | grep foo` searches everything.
# Replaces Oh My Zsh's `history` alias, which calls omz_history.
unalias history 2>/dev/null
history() {
  if [[ ! -t 1 || $1 == -c ]]; then
    omz_history "$@"
    return
  fi
  local arg has_range=0
  for arg in "$@"; do
    [[ $arg == <-> || $arg == -<-> ]] && has_range=1
  done
  (( has_range )) || set -- "$@" -30
  omz_history "$@" | awk '
    BEGIN { dim = "\033[2m"; green = "\033[32m"; cyan = "\033[36m"
            yellow = "\033[33m"; magenta = "\033[35m"; off = "\033[0m" }
    {
      # Split off the line number (plus the date and time, with `history -i`).
      match($0, /^ *[0-9]+\*? +([0-9-]+ [0-9:]+ +)?/)
      out = dim substr($0, 1, RLENGTH) off
      n = split(substr($0, RLENGTH + 1), word, " ")
      want_cmd = 1; quote = ""
      for (i = 1; i <= n; i++) {
        w = word[i]; first = substr(w, 1, 1); last = substr(w, length(w))
        if (quote != "") {
          color = yellow
          if (last == quote) quote = ""
        } else if (w == "|" || w == "||" || w == "&&" || w == ";") {
          color = magenta; want_cmd = 1
        } else if (want_cmd) {
          color = green; want_cmd = 0
        } else if (first == "-") {
          color = cyan
        } else if (first == "\"" || first == "\047") {
          color = yellow
          if (length(w) == 1 || last != first) quote = first
        } else {
          color = ""
        }
        out = out (i > 1 ? " " : "") (color == "" ? w : color w off)
      }
      print out
    }'
}

# Full history ("history all"), colored.
alias hall="history 1"

# ----------------------------------------------------------------------------
# Safer rm
# ----------------------------------------------------------------------------

# Make rm move things to the Bin (using macOS's `trash` command) so they can be
# recovered. Habits like `rm -rf node_modules` keep working: trash doesn't
# accept -r/-f/-i/-v, so those flags are dropped. Only affects this
# interactive shell; scripts still use the real rm. To delete permanently,
# use `command rm -rf ...`.
rm() {
  local -a files
  local arg end_of_flags=0
  for arg in "$@"; do
    if (( ! end_of_flags )) && [[ $arg == -- ]]; then
      # `--` means everything after it is a file name, even if it starts with "-".
      end_of_flags=1
    elif (( ! end_of_flags )) && [[ $arg =~ '^-[rRfiv]+$' ]]; then
      # An rm flag such as -rf; trash doesn't need it.
      continue
    else
      # trash has no `--`, so keep names like "-foo" from looking like flags.
      [[ $arg == -* ]] && arg="./$arg"
      files+=("$arg")
    fi
  done
  trash "${files[@]}"
}

# ----------------------------------------------------------------------------
# Environment
# ----------------------------------------------------------------------------

# Editor for git, crontab, Ctrl-X Ctrl-E, etc.
export EDITOR="zed --wait"
export VISUAL="zed --wait"

# Personal scripts and tools installed per user (e.g. by pipx or uv).
export PATH="$HOME/.local/bin:$PATH"

# ----------------------------------------------------------------------------
# Tools
# ----------------------------------------------------------------------------

# fzf, a fuzzy finder. https://github.com/junegunn/fzf
#   Ctrl-R  search command history
#   Ctrl-T  pick a file and paste its path
#   Alt-C   pick a folder and cd into it (needs Option set as Meta in the terminal)
source <(fzf --zsh)

# zoxide, a cd that learns. https://github.com/ajeetdsouza/zoxide
#   z foo   jump to the most-used folder matching "foo"
#   zi      choose from matching folders interactively
eval "$(zoxide init zsh)"

# ----------------------------------------------------------------------------
# Local overrides
# ----------------------------------------------------------------------------

# Machine-specific settings and secrets (API keys, tokens, work aliases) go in
# ~/.zshrc.local, which is not part of the dotfiles repo.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Colors commands as you type: green when valid, red when not.
# Must be loaded last so it can hook into everything set up above.
source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
