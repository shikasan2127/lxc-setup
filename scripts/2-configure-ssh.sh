#!/bin/bash

# SSH設定スクリプト
# パスワード認証を無効化し、鍵認証のみを許可する

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/lib/logging.sh"

# SSH設定ファイルのパス
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CONFIG_BACKUP="${SSHD_CONFIG}.bak"

log_info "Starting SSH security configuration..."

# root権限チェック
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

# SSH設定の構成
configure_ssh() {
    log_info "Configuring SSH security settings..."

    # sshd_configのバックアップを作成
    if [ ! -f "$SSHD_CONFIG_BACKUP" ]; then
        log_info "Creating backup of sshd_config..."
        cp "$SSHD_CONFIG" "$SSHD_CONFIG_BACKUP"
        log_info "Backup created at ${SSHD_CONFIG_BACKUP}"
    else
        log_warn "Backup already exists at ${SSHD_CONFIG_BACKUP}"
    fi

    # パスワード認証を無効化
    log_info "Disabling password authentication..."

    # PasswordAuthenticationの設定を変更
    if grep -q "^PasswordAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$SSHD_CONFIG"
        sed -i 's/^PasswordAuthentication no/PasswordAuthentication no/' "$SSHD_CONFIG"
    elif grep -q "^#PasswordAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' "$SSHD_CONFIG"
        sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/' "$SSHD_CONFIG"
    else
        echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
    fi

    # ChallengeResponseAuthenticationを無効化（古い設定名）
    if grep -q "ChallengeResponseAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^#*ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
        sed -i 's/^#*ChallengeResponseAuthentication no/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
    fi

    # KbdInteractiveAuthenticationを無効化（新しい設定名）
    if grep -q "^KbdInteractiveAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/' "$SSHD_CONFIG"
    elif grep -q "^#KbdInteractiveAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^#KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/' "$SSHD_CONFIG"
        sed -i 's/^#KbdInteractiveAuthentication no/KbdInteractiveAuthentication no/' "$SSHD_CONFIG"
    else
        echo "KbdInteractiveAuthentication no" >> "$SSHD_CONFIG"
    fi

    # 公開鍵認証を明示的に有効化
    if grep -q "^PubkeyAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^PubkeyAuthentication no/PubkeyAuthentication yes/' "$SSHD_CONFIG"
    elif grep -q "^#PubkeyAuthentication" "$SSHD_CONFIG"; then
        sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' "$SSHD_CONFIG"
        sed -i 's/^#PubkeyAuthentication no/PubkeyAuthentication yes/' "$SSHD_CONFIG"
    else
        echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
    fi

    log_info "SSH configuration changes applied:"
    log_info "  - PasswordAuthentication: no"
    log_info "  - KbdInteractiveAuthentication: no"
    log_info "  - PubkeyAuthentication: yes"
}

# 設定ファイルの検証
validate_ssh_config() {
    log_info "Validating SSH configuration..."

    if sshd -t 2>&1; then
        log_info "SSH configuration is valid."
        return 0
    else
        log_error "SSH configuration validation failed!"
        return 1
    fi
}

# SSHDサービスの再起動
restart_sshd() {
    log_info "Restarting SSH service..."

    # sshdまたはsshサービス名を判定
    if systemctl list-units --type=service | grep -q "sshd.service"; then
        SERVICE_NAME="sshd"
    elif systemctl list-units --type=service | grep -q "ssh.service"; then
        SERVICE_NAME="ssh"
    else
        log_error "SSH service not found"
        return 1
    fi

    if systemctl restart "$SERVICE_NAME"; then
        log_info "SSH service (${SERVICE_NAME}) restarted successfully."

        # サービスの状態を確認
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            log_info "SSH service is active and running."
            return 0
        else
            log_error "SSH service failed to start properly."
            return 1
        fi
    else
        log_error "Failed to restart SSH service."
        return 1
    fi
}

# ロールバック関数
rollback_config() {
    log_error "Rolling back to previous configuration..."
    if [ -f "$SSHD_CONFIG_BACKUP" ]; then
        cp "$SSHD_CONFIG_BACKUP" "$SSHD_CONFIG"
        systemctl restart sshd || systemctl restart ssh
        log_info "Configuration rolled back successfully."
    else
        log_error "No backup found for rollback!"
    fi
}

# メイン処理
main() {
    # SSH設定を構成
    configure_ssh

    # 設定ファイルを検証
    if ! validate_ssh_config; then
        rollback_config
        exit 1
    fi

    # SSHDサービスを再起動
    if ! restart_sshd; then
        rollback_config
        exit 1
    fi

    log_info "SSH security configuration completed successfully."
    log_warn "WARNING: Password authentication is now disabled."
    log_warn "Make sure you have SSH key access configured before disconnecting!"
}

# スクリプト実行
main
