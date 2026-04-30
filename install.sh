#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
SKILL_DIR="$CLAUDE_DIR/skills/professor-review"
COMMAND_DIR="$CLAUDE_DIR/commands"
AGENT_DIR="$CLAUDE_DIR/agents"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_file() {
    local src="$1"
    local dest="$2"
    if [[ -f "$dest" ]]; then
        echo "  SKIP  $dest already exists (delete it first to reinstall)"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  OK    $dest"
}

echo "Installing professor-review to $CLAUDE_DIR"
install_file "$REPO_ROOT/src/skill/SKILL.md"               "$SKILL_DIR/SKILL.md"
install_file "$REPO_ROOT/src/command/vibe-review.md"       "$COMMAND_DIR/vibe-review.md"
install_file "$REPO_ROOT/src/command/vibe-test.md"         "$COMMAND_DIR/vibe-test.md"
install_file "$REPO_ROOT/src/agent/professor-advisor.md"   "$AGENT_DIR/professor-advisor.md"
install_file "$REPO_ROOT/src/agent/professor-reviewer.md"  "$AGENT_DIR/professor-reviewer.md"
install_file "$REPO_ROOT/src/agent/professor-security.md"  "$AGENT_DIR/professor-security.md"
install_file "$REPO_ROOT/src/agent/professor-fixer.md"     "$AGENT_DIR/professor-fixer.md"

echo ""
echo "Done. Restart Claude Code (or run /reload) to pick up the new skill, command, and agent."
echo "Then try: /vibe-review path/to/your/code"
