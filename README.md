# Hugo 博客自动化部署系统

基于 Hugo + PaperMod 主题的个人博客，集成 Obsidian 笔记管理，通过 GitHub Actions 实现完全自动化的 CI/CD 部署流程。

## 📊 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    完整工作流程                              │
└─────────────────────────────────────────────────────────────┘

  📝 Obsidian 编辑                    🎨 主题配置
       │                                   │
       ▼                                   ▼
┌──────────────────┐              ┌──────────────────┐
│ obsidian-notes   │              │  hugo-server     │
│ (内容仓库)       │◄─────────────│  (主仓库)        │
│                  │   submodule  │                  │
└────────┬─────────┘              └────────┬─────────┘
         │ git push                        │ git push
         │                                 │
         ▼                                 ▼
┌────────────────────────────────────────────────────┐
│          GitHub Actions (自动触发)                  │
│  ┌──────────────────┐    ┌───────────────────┐    │
│  │ Trigger Workflow │───▶│ Build & Deploy    │    │
│  │ (obsidian-notes) │    │ (hugo-server)     │    │
│  └──────────────────┘    └─────────┬─────────┘    │
│                                    │               │
└────────────────────────────────────┼───────────────┘
                                     │
                                     ▼
                          ┌────────────────────┐
                          │  GitHub Pages      │
                          │  JiashuaiXu.github │
                          │  .io               │
                          └────────────────────┘
```

## 🗂️ 仓库结构

### 主仓库：hugo-server

```
hugo-server/
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions 自动部署配置
├── jesse-blog/                     # Hugo 站点目录
│   ├── content/                    # 📝 内容目录 (submodule → obsidian-notes)
│   ├── themes/
│   │   └── hugo-PaperMod/         # 🎨 PaperMod 主题 (submodule)
│   ├── public/                     # 🚫 构建输出 (gitignore，由 Actions 生成)
│   └── hugo.toml                   # ⚙️  Hugo 配置文件
├── dev.sh                          # 🔧 本地预览脚本
├── deploy.sh                       # ⚠️  已弃用提示
├── SETUP_GUIDE.md                  # 📘 详细配置指南
├── .gitignore                      # 忽略 public/ 目录
└── README.md                       # 📖 本文档
```

### 内容仓库：obsidian-notes

```
obsidian-notes/
├── .github/
│   └── workflows/
│       └── trigger-hugo.yml        # 触发 hugo-server 构建的 workflow
├── posts/                          # 博客文章目录
├── about/                          # 关于页面
└── archive/                        # 归档内容
```

### 部署仓库：JiashuaiXu.github.io

```
JiashuaiXu.github.io/
└── (由 GitHub Actions 自动生成和更新的静态网站文件)
```

## 🚀 快速开始

### 前置要求

- ✅ 已配置 GitHub Personal Access Token (权限: `repo`, `workflow`)
- ✅ 在两个仓库添加 Secret: `GH_PAT`
- ✅ 本地安装 Hugo (用于预览)

### 初次配置

1. **克隆仓库并初始化子模块**

```bash
git clone --recursive git@github.com:JiashuaiXu/hugo-server.git
cd hugo-server
```

2. **配置 GitHub Secrets**

   参考 [SETUP_GUIDE.md](./SETUP_GUIDE.md) 完成配置：
   - hugo-server: 添加 `GH_PAT`
   - obsidian-notes: 添加 `GH_PAT`

3. **本地预览**

```bash
./dev.sh
```

访问配置的 URL (默认: http://192.168.100.140:1313)

## 📝 日常使用

### 1. 写作和发布文章

#### 方式 A：在 Obsidian 中编辑

1. 打开 Obsidian，vault 路径设为 `jesse-blog/content` 或 `obsidian-notes` 仓库
2. 编辑或创建 Markdown 文章
3. 提交并推送：

```bash
cd jesse-blog/content  # 或 obsidian-notes 仓库目录
git add .
git commit -m "Add: 新文章标题"
git push
```

#### 方式 B：直接在终端编辑

```bash
cd /path/to/hugo-server/jesse-blog/content/posts
vim my-new-post.md  # 或使用其他编辑器
cd ..
git add .
git commit -m "Add: 新文章标题"
git push
```

✨ **自动触发流程**：
1. obsidian-notes workflow 检测到 .md 文件变更
2. 触发 hugo-server 的 `repository_dispatch` 事件
3. hugo-server 拉取最新内容 → 构建 → 部署到 GitHub Pages

⏱️ **预计 2-5 分钟后**，新文章出现在 https://JiashuaiXu.github.io

### 2. 本地预览（修改主题/调试样式）

```bash
# 基本预览（默认配置）
./dev.sh

# 自定义 bind 地址
./dev.sh 0.0.0.0

# 完全自定义
./dev.sh 0.0.0.0 http://192.168.1.100:1313
```

**用途**：
- 实时预览主题修改
- 调试文章排版
- 测试新功能

### 3. 修改主题或配置

```bash
# 1. 编辑配置
vim jesse-blog/hugo.toml

# 2. 本地预览效果
./dev.sh

# 3. 满意后提交
git add jesse-blog/
git commit -m "Update: 调整主题配置"
git push
```

✨ **自动触发**：hugo-server 检测到配置或主题变更 → 构建部署

### 4. 手动触发部署

访问 GitHub Actions 页面：
https://github.com/JiashuaiXu/hugo-server/actions/workflows/deploy.yml

点击 **Run workflow** 按钮

## ⚙️ 核心配置

### Hugo 配置文件

位置：`jesse-blog/hugo.toml`

关键配置项：

```toml
baseURL = "https://JiashuaiXu.github.io/"
languageCode = "zh-cn"
title = "Jesse's Blog"
theme = "hugo-PaperMod"

[params]
  defaultTheme = "auto"
  showReadingTime = true
  showShareButtons = true
  showPostNavLinks = true
  # ... 更多 PaperMod 配置
```

### 文章 Front Matter 模板

```yaml
---
title: "文章标题"
date: 2025-11-18T10:00:00+08:00
draft: false
tags: ["标签1", "标签2"]
categories: ["分类"]
description: "文章简介"
---

# 文章内容

这里是正文...
```

### Obsidian 配置

**Vault 路径**：
- 选项 1：`/path/to/hugo-server/jesse-blog/content`
- 选项 2：独立克隆 `obsidian-notes` 仓库

**模板配置**（推荐）：

在 Obsidian 设置 → 模板 → 模板文件夹，创建 `blog-post.md`：

```yaml
---
title: "{{title}}"
date: {{date:YYYY-MM-DDTHH:mm:ss+08:00}}
draft: false
tags: []
categories: []
---

# {{title}}

```

## 🔧 GitHub Actions 详解

### hugo-server/.github/workflows/deploy.yml

```yaml
name: Build and Deploy Hugo Site

on:
  repository_dispatch:      # obsidian-notes 触发
    types: [content-updated]
  workflow_dispatch:        # 手动触发
  push:                     # 配置/主题变更触发
    branches: [main]
    paths:
      - 'jesse-blog/hugo.toml'
      - 'jesse-blog/themes/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout with submodules
      - name: Update content to latest
      - name: Setup Hugo
      - name: Build site
      - name: Deploy to GitHub Pages
```

**触发条件**：
1. ✅ obsidian-notes 内容更新
2. ✅ 主题或配置文件变更
3. ✅ 手动触发

### obsidian-notes/.github/workflows/trigger-hugo.yml

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
      - name: Call hugo-server API
        run: |
          curl -X POST \
            -H "Authorization: token ${{ secrets.GH_PAT }}" \
            https://api.github.com/repos/JiashuaiXu/hugo-server/dispatches \
            -d '{"event_type":"content-updated"}'
```

**作用**：检测到内容变更 → 触发 hugo-server 构建

## 📦 依赖管理

### Git Submodules

查看子模块状态：

```bash
git submodule status
```

更新子模块：

```bash
# 更新所有子模块
git submodule update --remote --merge

# 更新特定子模块
git submodule update --remote --merge jesse-blog/content
```

初始化子模块（新克隆时）：

```bash
git submodule update --init --recursive
```

### 主题更新

PaperMod 主题作为子模块管理：

```bash
cd jesse-blog/themes/hugo-PaperMod
git pull origin master
cd ../../..
git add jesse-blog/themes/hugo-PaperMod
git commit -m "Update: PaperMod theme to latest"
git push
```

## 🐛 故障排查

### 问题 1：Actions 构建失败

**检查步骤**：

1. 查看 Actions 日志：
   - https://github.com/JiashuaiXu/hugo-server/actions
   - https://github.com/JiashuaiXu/obsidian-notes/actions

2. 常见原因：
   - ❌ `GH_PAT` secret 未配置或已过期
   - ❌ Token 权限不足（需要 `repo` + `workflow`）
   - ❌ Hugo 语法错误（检查文章 front matter）

**解决方案**：

重新生成 token：https://github.com/settings/tokens

### 问题 2：内容更新未触发构建

**排查**：

1. 检查 obsidian-notes workflow 是否执行
2. 确认推送的文件路径符合 `paths` 配置
3. 验证 `GH_PAT` 在 obsidian-notes 中已配置

**手动触发**：

访问 hugo-server Actions 页面手动运行

### 问题 3：本地预览失败

**检查**：

```bash
# 验证 Hugo 安装
hugo version

# 检查子模块
git submodule status

# 重新初始化子模块
git submodule update --init --recursive
```

### 问题 4：文章不显示

**可能原因**：

1. `draft: true` 未改为 `false`
2. `date` 时间在未来
3. Front matter 格式错误

**解决**：

```bash
# 使用 -D 参数显示草稿
hugo server -D
```

## 🔐 安全注意事项

### Token 管理

- ⚠️ 永远不要在代码中硬编码 token
- ✅ 仅通过 GitHub Secrets 使用
- ✅ 定期轮换 token
- ✅ 使用最小权限原则

### 私有内容

如果有不想公开的内容：

1. 在 obsidian-notes 中使用 `.gitignore`
2. 或创建独立的私有 Obsidian vault

## 📚 资源链接

### 仓库

- **主仓库**: https://github.com/JiashuaiXu/hugo-server
- **内容仓库**: https://github.com/JiashuaiXu/obsidian-notes
- **部署站点**: https://JiashuaiXu.github.io

### GitHub Actions

- **hugo-server Actions**: https://github.com/JiashuaiXu/hugo-server/actions
- **obsidian-notes Actions**: https://github.com/JiashuaiXu/obsidian-notes/actions

### 文档

- **Hugo 官方文档**: https://gohugo.io/documentation/
- **PaperMod 主题**: https://github.com/adityatelange/hugo-PaperMod
- **GitHub Actions 文档**: https://docs.github.com/en/actions

## 🎯 最佳实践

### 文章组织

```
posts/
├── 2025/
│   ├── 01-january/
│   │   └── article-name.md
│   └── 02-february/
│       └── another-article.md
└── drafts/          # 草稿（设置 draft: true）
    └── wip.md
```

### 提交信息规范

```bash
# 新文章
git commit -m "Add: 文章标题"

# 更新文章
git commit -m "Update: 修改文章标题"

# 修复
git commit -m "Fix: 修复拼写错误"

# 配置变更
git commit -m "Config: 调整主题配色"
```

### 图片管理

```
content/
├── posts/
│   └── my-post.md
└── images/
    └── my-post/
        └── screenshot.png
```

文章中引用：

```markdown
![描述](/images/my-post/screenshot.png)
```

## 🆚 架构对比

### 旧架构（已废弃）

```
❌ 问题：
- public/ 作为 submodule → commit 引用冲突
- 手动运行 deploy.sh → 与 Actions 冲突
- 需要管理多个 submodule 状态
```

### 新架构（当前）

```
✅ 优势：
- public/ 是临时构建产物 → 不追踪，无冲突
- 完全自动化 → 推送即部署
- 简化的 submodule 管理 → 仅 content 和 themes
```

## 💡 进阶技巧

### 评论系统

博客已配置 Giscus 评论系统（基于 GitHub Discussions）。

**配置步骤**：

查看详细指南：[GISCUS_SETUP.md](./GISCUS_SETUP.md)

快速配置：

1. 启用 GitHub Discussions：https://github.com/JiashuaiXu/hugo-server/settings
2. 安装 Giscus App：https://github.com/apps/giscus
3. 获取配置：https://giscus.app/zh-CN
4. 更新 `jesse-blog/hugo.toml` 中的 `repoId` 和 `categoryId`

**禁用评论**（可选）：

```toml
[params.comments]
  enabled = false
```

### 自定义域名

在 `hugo.toml` 中：

```toml
baseURL = "https://yourdomain.com/"
```

在 GitHub Pages 仓库设置中配置 Custom domain

### 评论系统

PaperMod 支持多种评论系统，编辑 `hugo.toml`：

```toml
[params.comments]
  giscus = true
  # 配置 giscus 参数
```

### SEO 优化

```toml
[params]
  description = "博客描述"
  images = ["/images/site-cover.png"]
  
[params.schema]
  publisherType = "Person"
```

### RSS Feed

默认启用，访问：`https://JiashuaiXu.github.io/index.xml`

## 🔄 维护清单

### 每周

- [ ] 检查 GitHub Actions 执行状态
- [ ] 查看 token 过期时间

### 每月

- [ ] 更新 PaperMod 主题
- [ ] 检查并更新 Hugo 版本

### 每季度

- [ ] 轮换 GitHub Personal Access Token
- [ ] 审查和清理旧草稿

## 📞 获取帮助

遇到问题？

1. 查阅 [SETUP_GUIDE.md](./SETUP_GUIDE.md)
2. 检查 GitHub Actions 日志
3. 参考 Hugo 和 PaperMod 官方文档

---

**最后更新**: 2025-11-18

**维护者**: JiashuaiXu

**许可证**: MIT
