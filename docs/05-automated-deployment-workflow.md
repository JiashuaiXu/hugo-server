# 功能5: 全流程自动化部署

## 功能说明

本系统实现了从 Obsidian 笔记编辑到 GitHub Pages 自动发布的完整自动化流程，无需手动构建或部署。

## 实现效果

- ✅ **内容更新自动部署**: 在 obsidian-notes 仓库推送 Markdown 文件后，自动触发构建和部署
- ✅ **配置更新自动部署**: 修改主题配置或主题文件后，自动重新构建
- ✅ **多仓库协同**: 通过 Git submodule 和 GitHub Actions 实现无缝集成
- ✅ **完全托管**: 使用 GitHub Actions 和 GitHub Pages，无需额外服务器

## 系统架构

```
┌─────────────────┐         ┌─────────────────┐
│ obsidian-notes  │         │  hugo-server    │
│  (内容仓库)      │◄────────│   (主仓库)       │
│                 │submodule│                 │
└────────┬────────┘         └────────┬────────┘
         │ push                      │ push
         │ .md files                 │ config/theme
         ▼                           ▼
┌──────────────────────────────────────────────┐
│         GitHub Actions                       │
│  ┌────────────────┐    ┌──────────────────┐ │
│  │ trigger-hugo   │───▶│ build & deploy   │ │
│  │   .yml         │    │    .yml          │ │
│  └────────────────┘    └────────┬─────────┘ │
└─────────────────────────────────┼───────────┘
                                  │
                                  ▼
                      ┌──────────────────────┐
                      │   GitHub Pages       │
                      │ JiashuaiXu.github.io │
                      └──────────────────────┘
```

## 配置步骤

### 前置要求

- ✅ 已有三个 GitHub 仓库:
  - `hugo-server`: 主仓库
  - `obsidian-notes`: 内容仓库
  - `JiashuaiXu.github.io`: GitHub Pages 部署仓库

### 1. 创建 GitHub Personal Access Token

1. 访问 https://github.com/settings/tokens
2. 点击 **Generate new token (classic)**
3. 配置 Token:
   - Note: `Hugo Blog Automation`
   - Expiration: 选择有效期
   - 权限勾选:
     - ✅ `repo` (全部子权限)
     - ✅ `workflow`
4. 点击 **Generate token**
5. **立即复制 token** (离开页面后将无法再次查看)

### 2. 配置仓库 Secrets

在两个仓库中添加 Secret `GH_PAT`:

**hugo-server 仓库**:
1. 访问 https://github.com/JiashuaiXu/hugo-server/settings/secrets/actions
2. 点击 **New repository secret**
3. Name: `GH_PAT`
4. Secret: 粘贴刚才创建的 token
5. 点击 **Add secret**

**obsidian-notes 仓库**:
1. 访问 https://github.com/JiashuaiXu/obsidian-notes/settings/secrets/actions
2. 重复相同步骤添加 `GH_PAT`

### 3. 配置 obsidian-notes 仓库的 GitHub Actions

创建文件 `.github/workflows/trigger-hugo.yml`:

```yaml
name: Trigger Hugo Build

on:
  push:
    branches: [main]
    paths:
      - '**.md'
      - 'posts/**'
      - 'about/**'
      - 'archive/**'

jobs:
  trigger-hugo-build:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger hugo-server repository_dispatch
        run: |
          curl -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${{ secrets.GH_PAT }}" \
            https://api.github.com/repos/JiashuaiXu/hugo-server/dispatches \
            -d '{"event_type":"content-updated"}'
```

提交并推送:

```bash
cd /path/to/obsidian-notes
git add .github/workflows/trigger-hugo.yml
git commit -m "Add: GitHub Actions workflow to trigger Hugo build"
git push
```

### 4. 配置 hugo-server 仓库的 GitHub Actions

创建文件 `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy Hugo Site

on:
  repository_dispatch:
    types: [content-updated]
  workflow_dispatch:
  push:
    branches: [main]
    paths:
      - 'jesse-blog/hugo.toml'
      - 'jesse-blog/themes/**'
      - 'jesse-blog/layouts/**'
      - 'jesse-blog/assets/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository with submodules
        uses: actions/checkout@v4
        with:
          submodules: true
          fetch-depth: 0

      - name: Update content submodule to latest
        run: |
          cd jesse-blog/content
          git checkout main
          git pull origin main
          cd ../..

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
          extended: true

      - name: Build Hugo site
        run: |
          cd jesse-blog
          hugo --gc --minify

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          personal_token: ${{ secrets.GH_PAT }}
          external_repository: JiashuaiXu/JiashuaiXu.github.io
          publish_dir: ./jesse-blog/public
          publish_branch: main
          user_name: 'github-actions[bot]'
          user_email: 'github-actions[bot]@users.noreply.github.com'
```

提交并推送:

```bash
cd /path/to/hugo-server
git add .github/workflows/deploy.yml
git commit -m "Add: GitHub Actions workflow for automated deployment"
git push
```

## 工作原理

### 触发流程

**场景 1: 内容更新**

1. 用户在 Obsidian 中编辑 Markdown 文件
2. 提交并推送到 obsidian-notes 仓库
3. obsidian-notes 的 `trigger-hugo.yml` 检测到 `.md` 文件变化
4. 通过 GitHub API 向 hugo-server 发送 `repository_dispatch` 事件
5. hugo-server 的 `deploy.yml` 被触发
6. 拉取最新内容，构建站点，部署到 GitHub Pages

**场景 2: 配置/主题更新**

1. 用户修改 `hugo.toml` 或主题文件
2. 推送到 hugo-server 仓库
3. `deploy.yml` 检测到相关文件变化，直接触发构建部署

**场景 3: 手动触发**

1. 访问 https://github.com/JiashuaiXu/hugo-server/actions/workflows/deploy.yml
2. 点击 **Run workflow** 按钮
3. 选择分支，点击 **Run workflow**

### 关键步骤解析

**1. Submodule 更新**
```bash
cd jesse-blog/content
git checkout main
git pull origin main
```
确保使用最新的内容文件。

**2. Hugo 构建**
```bash
hugo --gc --minify
```
- `--gc`: 清理缓存
- `--minify`: 压缩 HTML/CSS/JS

**3. 跨仓库部署**
```yaml
external_repository: JiashuaiXu/JiashuaiXu.github.io
publish_dir: ./jesse-blog/public
```
将构建产物推送到独立的 GitHub Pages 仓库。

## 日常使用

### 发布新文章

**方式 A: 使用 Obsidian**

1. 在 Obsidian 中打开 vault (指向 obsidian-notes 仓库)
2. 创建或编辑 Markdown 文件
3. 在 Obsidian 或终端中提交:

```bash
cd /path/to/obsidian-notes
git add .
git commit -m "Add: 新文章标题"
git push
```

4. 等待 2-5 分钟，查看 https://JiashuaiXu.github.io

**方式 B: 直接编辑**

```bash
cd /path/to/hugo-server/jesse-blog/content/posts
vim my-new-post.md
cd ../..
git add .
git commit -m "Add: 新文章标题"
git push
```

### 修改主题配置

```bash
cd /path/to/hugo-server
vim jesse-blog/hugo.toml

# 本地预览 (可选)
./dev.sh

# 提交并触发部署
git add jesse-blog/hugo.toml
git commit -m "Update: 调整主题配置"
git push
```

### 本地预览

```bash
# 基本预览
./dev.sh

# 指定监听地址
./dev.sh 0.0.0.0

# 完全自定义
./dev.sh 0.0.0.0 http://192.168.1.100:1313
```

## 监控部署状态

### 查看 GitHub Actions 执行情况

**hugo-server Actions**:
https://github.com/JiashuaiXu/hugo-server/actions

**obsidian-notes Actions**:
https://github.com/JiashuaiXu/obsidian-notes/actions

### 部署时间线

1. **0:00** - Push 到 obsidian-notes
2. **0:10** - trigger-hugo.yml 开始执行
3. **0:30** - hugo-server deploy.yml 被触发
4. **1:00** - Hugo 构建完成
5. **2:00** - 推送到 GitHub Pages 仓库
6. **3:00** - GitHub Pages 开始部署
7. **5:00** - 网站更新完成

## 故障排查

### 问题 1: 推送后未自动部署

**检查步骤**:

1. 查看 obsidian-notes Actions:
   - 确认 `trigger-hugo.yml` 是否执行
   - 查看日志是否有错误

2. 查看 hugo-server Actions:
   - 确认是否收到 `repository_dispatch` 事件
   - 查看构建日志

3. 验证 Secret 配置:
   ```bash
   # 检查 GH_PAT 是否正确配置
   # Settings → Secrets → Actions → GH_PAT
   ```

**常见原因**:

- ❌ `GH_PAT` 未配置或已过期
- ❌ Token 权限不足 (需要 `repo` + `workflow`)
- ❌ 推送的文件路径不在 `paths` 配置中
- ❌ workflow 文件有语法错误

**解决方案**:

```bash
# 重新生成 token
# 访问 https://github.com/settings/tokens
# 确保权限包含 repo 和 workflow

# 更新两个仓库的 GH_PAT Secret
# hugo-server/settings/secrets/actions
# obsidian-notes/settings/secrets/actions
```

### 问题 2: 构建失败

**检查 Hugo 构建日志**:

```bash
# 本地测试构建
cd jesse-blog
hugo --gc --minify
```

**常见错误**:

1. **Front Matter 格式错误**
```yaml
# 错误
---
title: 测试文章
date: 2025-11-20  # 缺少时区
---

# 正确
---
title: "测试文章"
date: 2025-11-20T10:00:00+08:00
---
```

2. **缺少必需字段**
```yaml
---
title: "文章标题"  # 必需
date: 2025-11-20T10:00:00+08:00  # 必需
draft: false  # 建议明确指定
---
```

3. **Markdown 语法问题**
- 检查是否有未闭合的代码块
- 检查是否有特殊字符未转义

### 问题 3: 部署成功但网站未更新

**检查 GitHub Pages 状态**:

1. 访问 https://github.com/JiashuaiXu/JiashuaiXu.github.io/settings/pages
2. 确认 Source 配置为:
   - Branch: `main`
   - Folder: `/` (root)

**清除浏览器缓存**:

```bash
# Chrome: Ctrl+Shift+R (硬刷新)
# Firefox: Ctrl+F5
# Safari: Cmd+Shift+R
```

**检查 DNS 和 CDN**:

GitHub Pages 使用 CDN，更新可能需要几分钟时间。

### 问题 4: Submodule 未更新

**手动更新 submodule**:

```bash
cd /path/to/hugo-server
git submodule update --remote --merge jesse-blog/content
git add jesse-blog/content
git commit -m "Update: content submodule"
git push
```

**检查 .gitmodules 配置**:

```bash
cat .gitmodules
```

应包含:

```ini
[submodule "jesse-blog/content"]
    path = jesse-blog/content
    url = https://github.com/JiashuaiXu/obsidian-notes.git
```

## 移除步骤

如需禁用自动部署:

### 1. 禁用 obsidian-notes 触发

```bash
cd /path/to/obsidian-notes
rm .github/workflows/trigger-hugo.yml
git add .
git commit -m "Remove: auto-trigger workflow"
git push
```

### 2. 禁用 hugo-server 自动部署

```bash
cd /path/to/hugo-server
rm .github/workflows/deploy.yml
git add .
git commit -m "Remove: auto-deploy workflow"
git push
```

### 3. 恢复手动部署 (可选)

如果需要恢复手动部署脚本，可以创建 `deploy.sh`:

```bash
#!/bin/bash
cd jesse-blog
hugo --gc --minify
cd public
git init
git add .
git commit -m "Deploy $(date)"
git push -f git@github.com:JiashuaiXu/JiashuaiXu.github.io.git main
cd ../..
```

## 自定义配置

### 修改触发路径

编辑 `obsidian-notes/.github/workflows/trigger-hugo.yml`:

```yaml
on:
  push:
    paths:
      - '**.md'              # 所有 .md 文件
      - 'posts/**'           # posts 目录
      - 'about/**'           # about 目录
      - '!drafts/**'         # 排除 drafts 目录
```

### 添加构建通知

在 `deploy.yml` 中添加:

```yaml
- name: Send notification
  if: success()
  run: |
    curl -X POST "YOUR_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d '{"text":"Blog deployed successfully!"}'
```

### 使用不同的 Hugo 版本

```yaml
- name: Setup Hugo
  uses: peaceiris/actions-hugo@v2
  with:
    hugo-version: '0.120.0'  # 指定版本
    extended: true
```

## 测试

### 完整流程测试

1. **创建测试文章**:

```bash
cd /path/to/obsidian-notes/posts
cat > test-deployment.md << 'TESTEOF'
---
title: "测试自动部署"
date: 2025-11-20T10:00:00+08:00
draft: false
tags: ["测试"]
---

# 测试自动部署

这是一篇测试文章。
TESTEOF
```

2. **提交并推送**:

```bash
git add test-deployment.md
git commit -m "Test: auto-deployment"
git push
```

3. **监控执行**:

- 访问 https://github.com/JiashuaiXu/obsidian-notes/actions
- 等待 `Trigger Hugo Build` 完成
- 访问 https://github.com/JiashuaiXu/hugo-server/actions
- 等待 `Build and Deploy Hugo Site` 完成

4. **验证结果**:

- 访问 https://JiashuaiXu.github.io
- 查看测试文章是否显示

5. **清理测试**:

```bash
rm test-deployment.md
git add test-deployment.md
git commit -m "Remove: test article"
git push
```

## 注意事项

- ⚠️ **Token 安全**: 永远不要在代码中硬编码 `GH_PAT`，只通过 GitHub Secrets 使用
- ⚠️ **Token 过期**: 定期检查并更新 Personal Access Token
- ⚠️ **构建时间**: 每次构建消耗 GitHub Actions 配额，注意使用量
- ⚠️ **Git Submodule**: 确保 submodule 配置正确，否则内容无法更新
- ⚠️ **Draft 文章**: 设置 `draft: true` 的文章不会被构建
- ⚠️ **缓存**: GitHub Pages 使用 CDN，更新可能有延迟

## 最佳实践

### 1. 提交信息规范

```bash
# 新文章
git commit -m "Add: 文章标题"

# 更新文章
git commit -m "Update: 文章标题"

# 修复
git commit -m "Fix: 修复拼写错误"

# 配置变更
git commit -m "Config: 调整主题设置"
```

### 2. 本地预览后再发布

```bash
# 在推送前本地预览
cd jesse-blog
hugo server -D  # 显示草稿

# 确认无误后
git push
```

### 3. 使用分支管理

```bash
# 创建功能分支
git checkout -b feature/new-article

# 完成后合并
git checkout main
git merge feature/new-article
git push
```

### 4. 定期维护

- 每月检查 Token 有效期
- 每季度更新 Hugo 版本
- 定期查看 Actions 执行历史

## 相关资源

- **GitHub Actions 文档**: https://docs.github.com/en/actions
- **Hugo 官方文档**: https://gohugo.io/documentation/
- **PaperMod 主题**: https://github.com/adityatelange/hugo-PaperMod
- **GitHub Personal Access Tokens**: https://github.com/settings/tokens

## 扩展阅读

- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - 详细配置指南
- [README.md](../README.md) - 系统架构说明
- [obsidian-notes/README.md](../jesse-blog/content/README.md) - Obsidian 集成指南
