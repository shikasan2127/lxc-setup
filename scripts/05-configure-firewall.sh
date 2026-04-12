#!/bin/bash

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/lib/logging.sh"

log_info "Starting firewall installation and configuration..."

# ファイアウォールのインストールと設定
log_info "Installing and configuring firewall..."
apt-get install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow from 192.168.1.0/24 to any port 22    # LAN内からのSSHを許可
ufw allow from 10.0.0.0/24 to any port 22       # VPN経由からのSSHを許可
ufw enable

log_info "Firewall installation and configuration completed successfully."
