#! /usr/bin/env bash
# Returns 0 (true) if inside a git repo whose toplevel has no .jj dir
git rev-parse --is-inside-work-tree 2>/dev/null || exit 1
toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
test ! -d "$toplevel/.jj"
