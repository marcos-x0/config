#! /usr/bin/env bash
# Returns 0 (true) if inside a jj-managed repo (not a git worktree)
toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
# If git toplevel has .jj, this is a jj repo
test -d "$toplevel/.jj"
