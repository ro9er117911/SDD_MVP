#!/usr/bin/env bash
# 共用工具：建立 Claude CLI 腳本測試環境

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURE_BRD="$REPO_ROOT/tests/fixtures/brd_analysis_sample.json"

create_run_env() {
    TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/speckit-cli-tests.XXXXXX")"
    export TEST_ROOT

    INPUT_DIR="$TEST_ROOT/input"
    OUTPUT_DIR="$TEST_ROOT/output"
    WORKSPACE_DIR="$TEST_ROOT/workspace"
    REMOTE_GIT_DIR="$TEST_ROOT/remote.git"
    MOCK_BIN_DIR="$TEST_ROOT/bin"
    LOG_DIR="$TEST_ROOT/logs"

    mkdir -p "$INPUT_DIR" "$OUTPUT_DIR" "$WORKSPACE_DIR" "$MOCK_BIN_DIR" "$LOG_DIR"

    cp "$FIXTURE_BRD" "$INPUT_DIR/brd_analysis.json"

    git init --bare "$REMOTE_GIT_DIR" >/dev/null

    git init "$WORKSPACE_DIR" >/dev/null
    git -C "$WORKSPACE_DIR" config user.name "Spec Bot"
    git -C "$WORKSPACE_DIR" config user.email "spec.bot@example.com"
    echo "# Initial README" > "$WORKSPACE_DIR/README.md"
    git -C "$WORKSPACE_DIR" add README.md
    git -C "$WORKSPACE_DIR" commit -m "chore: initial commit" >/dev/null
    git -C "$WORKSPACE_DIR" branch -M main >/dev/null
    git -C "$WORKSPACE_DIR" remote add origin "$REMOTE_GIT_DIR"
    git -C "$WORKSPACE_DIR" push -u origin main >/dev/null

    export INPUT_DIR OUTPUT_DIR WORKSPACE_DIR REMOTE_GIT_DIR
    export GITHUB_REPO="spec-bot/mock"
    export GITHUB_TOKEN="ghp_mock_token"
    export GH_TOKEN="$GITHUB_TOKEN"
    export ANTHROPIC_API_KEY="sk-ant-mock"
    export CLAUDE_MODEL="claude-mock"
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    export MOCK_CLAUDE_LOG="$LOG_DIR/claude_cli.log"
    export MOCK_MERMAID_LOG="$LOG_DIR/mermaid.log"

    setup_mock_bins
    export PATH="$MOCK_BIN_DIR:$PATH"
}

cleanup_run_env() {
    if [[ -n "${TEST_ROOT:-}" && -d "${TEST_ROOT:-}" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

setup_mock_bins() {
    cat > "$MOCK_BIN_DIR/claude-cli" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$#" -lt 2 || "$1" != "execute" ]]; then
    echo "[mock claude-cli] Unsupported command: $*" >&2
    exit 1
fi

CMD="$2"
: "${MOCK_CLAUDE_LOG:?Missing MOCK_CLAUDE_LOG}"
: "${WORKSPACE_DIR:?Missing WORKSPACE_DIR}"

echo "$CMD" >> "$MOCK_CLAUDE_LOG"

SPEC_DIR="$WORKSPACE_DIR/specs/001-spec-bot-sdd-integration"
mkdir -p "$SPEC_DIR"

case "$CMD" in
    */speckit.specify*)
        echo "# 模擬 Spec 內容" > "$SPEC_DIR/spec.md"
        ;;
    */speckit.plan*)
        echo "# 模擬 Plan 內容" > "$SPEC_DIR/plan.md"
        ;;
    */speckit.tasks*)
        echo "# 模擬 Tasks 內容" > "$SPEC_DIR/tasks.md"
        ;;
esac
EOF
    chmod +x "$MOCK_BIN_DIR/claude-cli"

    cat > "$MOCK_BIN_DIR/gh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$1" == "pr" && "$2" == "create" ]]; then
    echo "https://github.com/spec-bot/mock/pull/1"
else
    echo "[mock gh] Unsupported command: $*" >&2
    exit 1
fi
EOF
    chmod +x "$MOCK_BIN_DIR/gh"

    cat > "$MOCK_BIN_DIR/mmdc" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

INPUT_FILE=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i)
            INPUT_FILE="$2"
            shift 2
            ;;
        -o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
    echo "[mock mmdc] input file missing: $INPUT_FILE" >&2
    exit 1
fi

if [[ -n "$OUTPUT_FILE" ]]; then
    touch "$OUTPUT_FILE"
fi

echo "[mock mmdc] validated $INPUT_FILE" >> "${MOCK_MERMAID_LOG:-/tmp/mock-mermaid.log}"
EOF
    chmod +x "$MOCK_BIN_DIR/mmdc"
}
