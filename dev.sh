#!/bin/bash
# Hugo 本地预览脚本

set -e

# 自动获取本地局域网 IP
get_local_ip() {
    local ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | grep -E '^(192\.168|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.)' | head -1)
    if [ -z "$ip" ]; then
        ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    if [ -z "$ip" ]; then
        ip="0.0.0.0"
    fi
    echo "$ip"
}

DEFAULT_IP=$(get_local_ip)
BIND=${1:-"$DEFAULT_IP"}
BASE_URL=${2:-"http://$DEFAULT_IP:1313"}

echo "🚀 启动 Hugo 开发服务器..."
echo "   Bind: $BIND"
echo "   BaseURL: $BASE_URL"
echo ""
echo "💡 NixOS: 使用 'nix develop' 进入开发环境"
echo ""

cd jesse-blog
hugo server -D --bind "$BIND" --baseURL "$BASE_URL"
