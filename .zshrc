# --- Powerlevel10k instant prompt (must be at the very top, unchanged) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------- Safe helpers (no console output) --------------------
# Only run stty if we have an interactive TTY.
if [[ -t 0 ]]; then
  stty -ixon 2>/dev/null
fi

# Small guard to only run things if the command exists.
_exists() { command -v "$1" >/dev/null 2>&1; }

# ------------------------ History & completion ----------------------------
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY INC_APPEND_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY

autoload -Uz compinit
# Use a cache file, and suppress “insecure directories” chatter to avoid instant-prompt I/O.
# (Optional: run `compaudit` later and fix permissions properly.)
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump" -i

# ----------------------------- Keybindings --------------------------------
bindkey -v

# Incremental history search on ^R/^S
bindkey -M viins '^R'  history-incremental-pattern-search-backward
bindkey -M vicmd '^R'  history-incremental-pattern-search-backward
bindkey -M viins '^S'  history-incremental-pattern-search-forward
bindkey -M vicmd '^S'  history-incremental-pattern-search-forward

# Prefix history search on Up/Down
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey -M viins "${terminfo[kcuu1]}" history-beginning-search-backward
  bindkey -M viins "${terminfo[kcud1]}" history-beginning-search-forward
  bindkey -M vicmd "${terminfo[kcuu1]}" history-beginning-search-backward
  bindkey -M vicmd "${terminfo[kcud1]}" history-beginning-search-forward
else
  bindkey -M viins '^[[A' history-beginning-search-backward
  bindkey -M viins '^[[B' history-beginning-search-forward
  bindkey -M vicmd '^[[A' history-beginning-search-backward
  bindkey -M vicmd '^[[B' history-beginning-search-forward
fi

# A few Emacs keys in insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank

# ------------------------------ zoxide ------------------------------------
if _exists zoxide; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# ------------------------------- fzf --------------------------------------
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'
export FZF_CTRL_R_OPTS='--no-sort --exact'

if _exists fzf; then
  if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  else
    # Safe: printed script is consumed by source; no terminal I/O.
    source <(fzf --zsh)
  fi
  # Ensure Ctrl-R uses fzf’s history widget
  bindkey -M viins '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget

  # Optional: reuse fzf for forward search; stty already guarded above
  if typeset -f fzf-history-widget >/dev/null; then
    bindkey -M viins '^S' fzf-history-widget
    bindkey -M vicmd '^S' fzf-history-widget
  fi
fi

# --------------------------- Powerlevel10k --------------------------------
# If you installed via oh-my-zsh, prefer that path; otherwise fallback to your home clone.
if [[ -r "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -r "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

export PATH="$HOME/.local/bin:$PATH"

# Find text in files with fzf and open in vim
alias fl='/home/grego/Development/fl'
alias f='f(){ rg "$1" | bat | fzf; }; f'
