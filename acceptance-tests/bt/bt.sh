#!/usr/bin/env bash

. "${BT_ROOT_DIR}/lib/functions.sh"

function bt_call_functions_by_phase() {
    local -r phase="$1"
    local f

    while read -r f; do
        . <(echo "$f")
        rc=$?
        if [[ $rc -eq 0 ]]; then
            log "$f ${G}passed${Re}"
        else
            log "$f ${R}failed${Re}"
            bt_call_failure_hook "$phase" "$f"
        fi
    done < <(bt_get_functions_by_prefix "test_phase_${phase}")
}
