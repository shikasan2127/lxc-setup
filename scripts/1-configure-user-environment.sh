#!/bin/bash

# ユーザー環境設定スクリプト
# SSSD、PAM、ホームディレクトリの設定を行う

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/lib/logging.sh"

# ホスト名とホームディレクトリの設定
HOSTNAME=$(hostname)
HOME_DIR="/home/${HOSTNAME}"

log_info "Starting user environment configuration for ${HOSTNAME}..."

# 必要なパッケージのインストール
log_info "Installing required packages..."
apt-get update
apt-get install -y sssd realmd oddjob oddjob-mkhomedir

# SSSD（System Security Services Daemon）の設定
# ホームディレクトリのパスを指定
log_info "Configuring SSSD..."
if [ ! -f /etc/sssd/sssd.conf ]; then
    log_error "SSSD configuration file not found. Please install FreeIPA client first."
    exit 1
fi

# ホームディレクトリの設定を追加（既に存在する場合はスキップ）
if ! grep -q "override_homedir = ${HOME_DIR}" /etc/sssd/sssd.conf; then
    sed -i "/^\[domain\//a override_homedir = ${HOME_DIR}" /etc/sssd/sssd.conf
    log_info "SSSD home directory override configured: ${HOME_DIR}"
else
    log_info "SSSD home directory override already configured"
fi

chmod 600 /etc/sssd/sssd.conf

# PAM設定の修正
# ホームディレクトリの自動作成を無効化
log_info "Configuring PAM..."
if grep -q "^session.*pam_mkhomedir\.so" /etc/pam.d/common-session; then
    sed -i 's/^\(session\s\+\(required\|optional\)\s\+pam_mkhomedir\.so.*\)/# \1/' /etc/pam.d/common-session
    log_info "PAM mkhomedir disabled"
else
    log_info "PAM mkhomedir already disabled"
fi

# ホームディレクトリの作成と権限設定
log_info "Setting up home directory..."
if [ ! -d "${HOME_DIR}" ]; then
    mkdir -p "${HOME_DIR}"
    log_info "Created home directory: ${HOME_DIR}"
else
    log_info "Home directory already exists: ${HOME_DIR}"
fi

# 権限設定
# chown admin:ipausers "${HOME_DIR}"
chmod 777 "${HOME_DIR}"
log_info "Home directory permissions configured"

# SSSDサービスの再起動
log_info "Restarting SSSD service..."
systemctl restart sssd

log_info "User environment configuration completed for ${HOSTNAME}."
