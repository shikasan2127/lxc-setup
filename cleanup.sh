#!/bin/bash

set -e

ENV_FILE="/usr/bin/setup.env"

# ログ関数
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_info "Cleaning up setup service and script..."
rm -f "$SCRIPT_PATH"
rm -f "$ENV_FILE"
rm -rf ./"$REPO_DIR"
rm -f /root/.ssh/lxc_template_key
systemctl disable "$SERVICE_NAME"
rm -f "$SERVICE_PATH"
systemctl daemon-reload
rm -f /var/run/lxc-setup.lock
log_info "Cleanup completed successfully"
