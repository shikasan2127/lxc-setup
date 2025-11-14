#!/bin/bash

# FreeIPAクライアントのインストールスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/lib/logging.sh"

# FreeIPA設定パラメータ
REALM="EXAMPLE.HOME"
DOMAIN="example.home"
IPA_SERVER="ipa.example.home"
ADMIN_USER="admin"
ADMIN_PASS="$IPA_ADMIN_PASS"

# 必須環境変数の確認
if [ -z "$IPA_ADMIN_PASS" ]; then
    log_error "Environment variable IPA_ADMIN_PASS is required"
    log_error "Please set IPA_ADMIN_PASS environment variable in systemd service"
    exit 1
fi

# FQDN（完全修飾ドメイン名）を取得
HOSTNAME=$(hostname -f | tr '[:upper:]' '[:lower:]')

log_info "Starting FreeIPA client installation for ${HOSTNAME}..."

# 必要なパッケージのインストール
log_info "Installing required packages..."
apt-get update
apt-get install -y freeipa-client

# FreeIPAクライアントの自動インストール
# --unattended: 対話的な設定を無効化
# --force-join: 既存の設定があっても強制的に参加
log_info "Installing FreeIPA client..."
ipa-client-install \
    --unattended \
    --principal="${ADMIN_USER}" \
    --password="${ADMIN_PASS}" \
    --hostname="${HOSTNAME}" \
    --server="${IPA_SERVER}" \
    --domain="${DOMAIN}" \
    --realm="${REALM}" \
    --force-join \
    --no-ntp \
    --enable-dns-updates

log_info "FreeIPA client installation completed for ${HOSTNAME}."

# セキュリティのため環境変数をクリア
unset ADMIN_PASS
unset IPA_ADMIN_PASS

log_info "FreeIPA client installation process completed successfully."