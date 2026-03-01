#!/usr/bin/env bash
# Tests for uninstall.sh — verifies all traces are removed except the repo.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

assert() {
    local desc="$1"
    if eval "$2"; then
        echo "  PASS: $desc"
        PASS=$(( PASS + 1 ))
    else
        echo "  FAIL: $desc"
        FAIL=$(( FAIL + 1 ))
    fi
}

setup() {
    TEMP_DIR=$(mktemp -d)
    FAKE_HOME="$TEMP_DIR/home"
    FAKE_XDG="$TEMP_DIR/xdg"
    FAKE_BASHRC="$FAKE_HOME/.bashrc"
    FAKE_DEPS_DIR="$FAKE_XDG/nikitas_dotfiles"
    FAKE_DEPS_FILE="$FAKE_DEPS_DIR/installed_deps"

    mkdir -p "$FAKE_HOME" "$FAKE_DEPS_DIR"

    # Fake .bashrc with the source line
    SOURCE_LINE="source \"$DOTFILES_DIR/bash/init.sh\""
    printf '# existing content\n\n# nikitas_dotfiles\n%s\n' "$SOURCE_LINE" > "$FAKE_BASHRC"

    # Empty deps file (no real packages, avoids actual apt calls)
    touch "$FAKE_DEPS_FILE"

    # Fake sudo + apt so no real packages are touched
    FAKE_BIN="$TEMP_DIR/bin"
    mkdir -p "$FAKE_BIN"
    printf '#!/usr/bin/env bash\necho "fake apt: $*"\n' > "$FAKE_BIN/apt"
    printf '#!/usr/bin/env bash\n"$@"\n'               > "$FAKE_BIN/sudo"
    chmod +x "$FAKE_BIN/apt" "$FAKE_BIN/sudo"
}

teardown() {
    rm -rf "$TEMP_DIR"
}

test_uninstall() {
    echo "Running uninstall tests..."

    HOME="$FAKE_HOME" XDG_DATA_HOME="$FAKE_XDG" PATH="$FAKE_BIN:$PATH" \
        bash "$DOTFILES_DIR/uninstall.sh" > /dev/null 2>&1

    assert "source line removed from .bashrc" \
        "! grep -qF 'bash/init.sh' '$FAKE_BASHRC'"

    assert "nikitas_dotfiles comment removed from .bashrc" \
        "! grep -qF '# nikitas_dotfiles' '$FAKE_BASHRC'"

    assert "deps file removed" \
        "[[ ! -f '$FAKE_DEPS_FILE' ]]"

    assert "repo still exists" \
        "[[ -d '$DOTFILES_DIR' ]]"
}

setup
test_uninstall
teardown

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
