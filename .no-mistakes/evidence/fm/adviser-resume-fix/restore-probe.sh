#!/usr/bin/env bash
# Starts real Claude in a home from a shell WITHOUT COMPACT_ADVISER_DISABLE (as a
# Herdr native restore's fresh pane shell would), then resumes that same session
# with `claude --resume <id>`, and reports what Claude's own process env holds.
set -u
home=$1
P='Run exactly this shell command with the Bash tool and reply with ONLY its stdout, nothing else: printenv COMPACT_ADVISER_DISABLE || echo UNSET'
clean() { env -u COMPACT_ADVISER_DISABLE -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_SSE_PORT "$@"; }
cd "$home" || exit 1
echo "home=$home"; echo "launch shell COMPACT_ADVISER_DISABLE=$(clean sh -c 'printenv COMPACT_ADVISER_DISABLE || echo UNSET')"
out=$(clean claude -p "$P" --allowedTools Bash --output-format json </dev/null)
sid=$(printf '%s' "$out" | jq -r .session_id); echo "start: session=$sid result=$(printf '%s' "$out" | jq -r .result)"
out2=$(clean claude -p --resume "$sid" "$P" --allowedTools Bash --output-format json </dev/null)
echo "resume: session=$(printf '%s' "$out2" | jq -r .session_id) result=$(printf '%s' "$out2" | jq -r .result)"
