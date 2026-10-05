#!/usr/bin/env bash
# Drives the real bin/fm-spawn.sh --secondmate on claude (fake pane backend, real git home)
# and copies each resulting secondmate home to $LIVE for real-Claude checks.
set -u
cd "$1"; LIVE=$2
. tests/fixtures.sh
TMP_ROOT=$(fm_test_tmproot fm-adviser-live)
mk() { local name=$1 id=$2; local c=$TMP_ROOT/$name; local fb; fb=$(fm_test_make_spawn_fakebin "$c/fake")
  fm_test_spawn_home "$c/home" claude; fm_test_spawn_brief "$c/home" "$id"
  local sm=$c/secondmate-home; mkdir -p "$sm"; fm_git_init_commit "$sm" >/dev/null
  mkdir -p "$sm/bin" "$sm/data" "$sm/state" "$sm/config" "$sm/projects"
  printf '# Firstmate\n' > "$sm/AGENTS.md"; printf '%s\n' "$id" > "$sm/.fm-secondmate-home"
  printf 'charter\n' > "$sm/data/charter.md"
  if [ "${3:-}" = existing ]; then mkdir -p "$sm/.claude"; printf '%s\n' '{"autoCompactWindow":120000,"env":{"KEEP_ME":"yes"}}' > "$sm/.claude/settings.local.json"; fi
  echo "== spawn $name"
  FM_FAKE_LAUNCH_LOG="$c/launch.log" FM_FAKE_PANE_LOG="$c/pane.log" fm_test_run_spawn "$c/home" "$sm" "$fb" "$id" "$sm" claude --secondmate | tail -3
  echo "rc=${PIPESTATUS[0]}"
  echo "-- $name .claude/settings.local.json:"; cat "$sm/.claude/settings.local.json"
  echo "-- git status --porcelain (home):"; git -C "$sm" status --porcelain; echo "(end)"
  cp -R "$sm" "$LIVE/$name"
}
mk fresh sm-live-a1
mk existing sm-live-b1 existing
