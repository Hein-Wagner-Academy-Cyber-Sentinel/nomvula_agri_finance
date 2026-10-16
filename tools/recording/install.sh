#!/usr/bin/env bash
# Nomvula Agri Finance - Workflow Setup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_PATH="$SCRIPT_DIR/helpers.sh"
BASHRC="$HOME/.bashrc"

# 1. Ensure ~/.ssh/config exists for GitHub SSH
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ] || ! grep -q "Host github.com" "$HOME/.ssh/config"; then
    cat << 'EOF' >> "$HOME/.ssh/config"

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    IdentitiesOnly yes
EOF
    chmod 600 "$HOME/.ssh/config"
fi

# 2. Add helpers loader to ~/.bashrc if not already present
LOADER_SNIPPET="if [ -f \"$HELPERS_PATH\" ]; then
    source \"$HELPERS_PATH\"
fi"

if ! grep -qF "$HELPERS_PATH" "$BASHRC" 2>/dev/null; then
    echo -e "\n# Nomvula Agri Finance Recording & Git Flow Helpers\n$LOADER_SNIPPET\n" >> "$BASHRC"
fi

echo "Setup complete. All workflow commands are active in your bashrc."
