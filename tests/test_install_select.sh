#!/usr/bin/env bash
# Tests for the install.sh component selection layer (presets, custom picks,
# and the no-terminal fallback). No packages are touched: the component
# installers are stubbed out.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "  PASS: $desc"
        PASS=$(( PASS + 1 ))
    else
        echo "  FAIL: $desc (expected '$expected', got '$actual')"
        FAIL=$(( FAIL + 1 ))
    fi
}

assert_fails() {
    local desc="$1" cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  FAIL: $desc (command succeeded)"
        FAIL=$(( FAIL + 1 ))
    else
        echo "  PASS: $desc"
        PASS=$(( PASS + 1 ))
    fi
}

# Sourcing runs only the definitions; main is guarded by a BASH_SOURCE check.
# shellcheck source=/dev/null
source "$DOTFILES_DIR/install.sh"

# Record what main would install instead of installing it.
INSTALLED=()
install_shell_integration() { INSTALLED+=(shell); }
install_component() { INSTALLED+=("$1"); }

echo "Running install selection tests..."

assert_eq "full preset installs every component" \
    "fzf wezterm fonts clipboard" \
    "$(resolve_preset full | paste -sd ' ')"

assert_eq "minimal preset installs fzf only" \
    "fzf" \
    "$(resolve_preset minimal | paste -sd ' ')"

assert_fails "unknown preset is rejected" "resolve_preset bogus"

assert_eq "empty custom answer means all components" \
    "fzf wezterm fonts clipboard" \
    "$(parse_component_choice '' | paste -sd ' ')"

assert_eq "'none' custom answer means no components" \
    "" \
    "$(parse_component_choice 'none' | paste -sd ' ')"

assert_eq "comma-separated picks map to component ids" \
    "fzf fonts" \
    "$(parse_component_choice '1,3' | paste -sd ' ')"

assert_eq "space-separated picks map to component ids" \
    "wezterm clipboard" \
    "$(parse_component_choice '2 4' | paste -sd ' ')"

assert_fails "out-of-range pick is rejected" "parse_component_choice '9'"
assert_fails "non-numeric pick is rejected" "parse_component_choice 'wezterm'"

# No terminal on stdin/stdout: main must fall back to the full install.
INSTALLED=()
main </dev/null >/dev/null 2>&1
assert_eq "no-terminal run installs everything" \
    "shell fzf wezterm fonts clipboard" \
    "${INSTALLED[*]}"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
