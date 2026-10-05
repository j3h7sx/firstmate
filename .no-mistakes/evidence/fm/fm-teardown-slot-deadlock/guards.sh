#!/usr/bin/env bash
# Drives the real bin/fm-teardown.sh against disposable lab homes for the guard cases.
cd /Users/solodev/.no-mistakes/worktrees/06de476caf53/01M45TYF1AFXKHWX63P03TV0WV || exit 1
id=lull-appstore-copy
run() {
  label=$1; shift
  LAB=$(mktemp -d "${TMPDIR:-/tmp}/fm-lab.XXXXXX"); bin/fm-lab-home.sh create "$LAB" >/dev/null
  mkdir -p "$LAB/proj" && git init -q "$LAB/proj"
  printf "%s\n" "window=firstmate:fm-$id" "endpoint_task_id=$id" "project=$LAB/proj" "$@" > "$LAB/state/$id.meta"
  [ "$label" = scout-no-report ] || { mkdir -p "$LAB/data/$id"; echo r > "$LAB/data/$id/report.md"; }
  echo "=== $label (fix 10c35cc) meta extra: $* ==="
  env -u FM_ROOT_OVERRIDE -u FM_STATE_OVERRIDE -u FM_DATA_OVERRIDE -u FM_CONFIG_OVERRIDE -u FM_PROJECTS_OVERRIDE -u TMUX \
    FM_HOME="$LAB" bin/fm-teardown.sh "$id" --force > "$LAB/out" 2>&1
  rc=$?
  grep -v "^●\|fm-gate-refuse" "$LAB/out"
  echo "exit=$rc; meta kept? $( [ -e "$LAB/state/$id.meta" ] && echo yes || echo no )"
  rm -rf "$LAB"
}
run ship-no-worktree kind=ship decisions_reviewed=1 decision_keys=
run scout-empty-worktree worktree= kind=scout decisions_reviewed=1 decision_keys=
run scout-no-report kind=scout decisions_reviewed=1 decision_keys=
run scout-gate-open kind=scout
