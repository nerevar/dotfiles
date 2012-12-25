#!/usr/bin/env bash

# Force create/replace the symlink.
link() {
    if [ -e $1 ]; then
        ln -fs "${DOTFILES_DIRECTORY}/${1}" "${HOME}/${2}"
    fi
}

# Test whether we're in a git repo
is_git_repo() {
    $(git rev-parse --is-inside-work-tree &> /dev/null)
}

# Test whether a command exists
# $1 - cmd to test
type_exists() {
    if [ $(type -P $1) ]; then
      return 0
    fi
    return 1
}