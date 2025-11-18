#!/bin/bash
# Hugo 本地预览脚本
#
# 用法:
#   ./dev.sh                                    # 使用默认配置
#   ./dev.sh 0.0.0.0                           # 自定义 bind
#   ./dev.sh 0.0.0.0 http://192.168.1.100:1313 # 自定义 bind 和 baseURL
#
# NixOS 用户:
#   nix develop           # 进入开发环境
#   cd jesse-blog && hugo server -D --bind 0.0.0.0 --baseURL http://192.168.100.140:1313

set -e

BIND=${1:-"0.0.0.0"}
BASE_URL=${2:-"http://192.168.100.140:1313"}

echo "🚀 启动 Hugo 开发服务器..."
echo "   Bind: $BIND"
echo "   BaseURL: $BASE_URL"
echo ""
echo "💡 提示: NixOS 用户可以使用 'nix develop' 进入开发环境"
echo ""

cd jesse-blog
hugo server -D --bind "$BIND" --baseURL "$BASE_URL"
