#!/bin/bash

# 基本的なアプリケーションのインストールスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/lib/logging.sh"

log_info "Starting application installation..."

# 基本的なツールのインストール
log_info "Installing basic packages..."
apt-get update
apt-get install -y vim less curl

# Dockerのインストール
# get.docker.comの公式スクリプトを使用
log_info "Installing Docker..."
curl -fsSL https://get.docker.com | sh

log_info "Application installation completed successfully."
