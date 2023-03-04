#!/usr/bin/env bash

function test_phase_setup() {
    echo "this is my setup phase"
    return 0
}

function test_phase_run() {
    echo "this is my run phase"
    return 0
}

function test_failed_hook_phase_run() {
    echo "test run failed."
    exit 1
}

function test_failed_hook_phase_setup() {
    echo "tests setup failed."
    exit 1
}
