#!/bin/bash

# 各スクリプトを順次実行し、エラー時は即座に終了する
set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ログ関数を読み込み
source "${SCRIPT_DIR}/scripts/lib/logging.sh"

log_info "Starting setup process..."

# 番号付きスクリプトを順番に実行
# スクリプトは [0-9]-*.sh の形式で命名されている
for script in "${SCRIPT_DIR}"/scripts/[0-9]-*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        log_info "Executing: scripts/${script_name}"

        if bash "$script"; then
            log_info "${script_name} completed successfully"
        else
            log_error "${script_name} failed with exit code $?"
            exit 1
        fi
    fi
done

# 番号付きスクリプトが1つも見つからなかった場合
if ! ls "${SCRIPT_DIR}"/scripts/[0-9]-*.sh 1> /dev/null 2>&1; then
    log_error "No numbered scripts found in scripts/ directory"
    log_error "Expected format: [0-9]-*.sh (e.g., 0-freeipa.sh, 1-appInstall.sh)"
    exit 1
fi

log_info "All setup scripts completed successfully"
