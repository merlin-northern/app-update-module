#!/usr/bin/env bash

export BT_ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")

. "${BT_ROOT_DIR}/bt.sh"

BT_DEFAULT_PHASES=(
    "setup"
    "build"
    "run"
    "collect"
)

if [[ "${#TEST_PHASES_NAMES[@]}" == "" || ${#TEST_PHASES_NAMES[@]} -lt 1 ]]; then
    TEST_PHASES_NAMES=()
    for ((i = 0; i < ${#BT_DEFAULT_PHASES[@]}; i++)); do
        TEST_PHASES_NAMES+=(${BT_DEFAULT_PHASES[${i}]})
    done
fi

while read -r scenario; do
    (
        . "$scenario"
        for ((i = 0; i < ${#TEST_PHASES_NAMES[@]}; i++)); do
            p="${TEST_PHASES_NAMES[${i}]}"
            bt_call_functions_by_phase "$p"
        done
    )
done < <(find "${1}" -mindepth 1 -maxdepth 1 -and -name "*.sh" -and -type f)
