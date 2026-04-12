#!/bin/bash

set -e

exec </dev/null

# ログ関数
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# コンテナの初期化
log_info "Starting container initialization..."
echo "start up container ..."

# 必要なパッケージのインストール
log_info "Installing required packages..."
apt-get update -y
apt-get install -y git

# リポジトリのクローン
log_info "Cloning repository..."
ssh-keyscan github.com >> /root/.ssh/known_hosts
if [ ! -d "$REPO_DIR" ]; then
    GIT_SSH_COMMAND='ssh -i /root/.ssh/lxc_template_key' git clone "$REPO_URL"
else
    log_info "Repository already exists, skipping clone"
fi

# セットアップスクリプトの実行
log_info "Executing setup script..."
chmod +x ./${REPO_DIR}/setup.sh
./${REPO_DIR}/setup.sh

log_info "Setup completed successfully"
