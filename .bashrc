# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# fnm
FNM_PATH="/home/jacocanete/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

bind -x '"\C-f": "fzf"'

# Enable Git branch display
parse_git_branch() {
  git branch 2>/dev/null | sed -n '/\* /s///p'
}

export PS1="\[\e[32m\]\u@\h\[\e[m\]:\[\e[34m\]\w\[\e[m\]\[\e[33m\] \$(parse_git_branch)\[\e[m\]\$ "
