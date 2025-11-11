#!/bin/sh
set -e

# 进入 Hugo 站点目录
cd jesse-blog

# 生成静态站点（输出到 public/） using nix develop environment
nix develop --command bash -c "hugo -D"

# 进入 public 目录
cd public

# 提交并推送到 GitHub Pages
git add .
git commit -m "Deploy Hugo site $(date +%Y-%m-%d)"
git push origin main

# 返回上级目录
cd ..

# 提交更新子模块的引用
git add public
git commit -m "Update submodule reference"
git push origin main  # 推送到 Hugo 站点仓库

