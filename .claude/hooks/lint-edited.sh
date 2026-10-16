#!/usr/bin/env bash
# PostToolUse hook: lint only the file just edited; exit 2 sends errors to Claude.
f=$(jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0
case "$f" in *.ts|*.tsx|*.js|*.jsx|*.mjs) ;; *) exit 0 ;; esac
[ -f "$f" ] || exit 0
out=$(vp lint "$f" 2>&1) || { echo "$out" >&2; exit 2; }
exit 0
