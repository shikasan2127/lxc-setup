#!/bin/bash

# 日本語フォントとロケールのインストールスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/lib/logging.sh"

log_info "Starting Japanese fonts and locales installation..."

# 日本語フォント、ロケールのインストールと設定
log_info "Installing Japanese fonts and locales..."
apt-get update
apt-get install -y fonts-noto-cjk fonts-ipafont
apt-get install -y language-pack-ja-base language-pack-ja
locale-gen ja_JP.UTF-8
echo 'export LC_CTYPE=ja_JP.UTF-8' >>~/.profile
source ~/.profile

log_info "Japanese fonts and locales installation completed successfully."
