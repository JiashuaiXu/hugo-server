# Hugo Blog Server

一个基于 [Hugo](https://gohugo.io/) 静态网站生成器构建的个人博客项目，使用 [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题，并通过 Nix Flakes 管理开发环境。支持使用 [Obsidian](https://obsidian.md/) 进行笔记写作和发布。

## 📋 项目简介

这是一个私有 GitHub 仓库，用于安全地存储博客源代码和配置。生成的静态网站通过 `public/` 目录关联到公开仓库 [JiashuaiXu.github.io](https://github.com/JiashuaiXu/JiashuaiXu.github.io)，用于 GitHub Pages 部署。

## ✨ 功能特性

- 🚀 **快速部署**：一键部署脚本，自动生成并推送到 GitHub Pages
- 🎨 **现代主题**：使用 Hugo PaperMod 主题，支持亮色/暗色模式自动切换
- 🔧 **环境管理**：通过 Nix Flakes 提供可复现的开发环境
- 📝 **Markdown 支持**：使用 Markdown 编写博客文章
- 🧠 **Obsidian 集成**：支持使用 Obsidian 进行笔记写作和发布工作流
- 🌐 **多语言支持**：可配置多语言内容
- 📱 **响应式设计**：适配各种设备屏幕

## 🛠️ 技术栈

- **静态网站生成器**：Hugo
- **主题**：hugo-PaperMod
- **环境管理**：Nix Flakes
- **笔记工具**：Obsidian
- **部署平台**：GitHub Pages
- **版本控制**：Git

## 📁 项目结构

```text
hugo-server/
├── jesse-blog/              # Hugo 站点（主目录）
│   ├── archetypes/          # 文章模板
│   ├── assets/              # 静态资源文件
│   ├── content/             # Markdown 博客文章
│   │   └── posts/           # 博客文章目录
│   ├── public/              # Hugo 生成的静态网站（Git 子模块）
│   ├── resources/           # Hugo 生成的资源文件
│   ├── themes/              # Hugo 主题目录
│   │   └── hugo-PaperMod/   # PaperMod 主题
│   └── hugo.toml            # Hugo 配置文件
├── deploy.sh                # 自动部署脚本
├── flake.nix                # Nix Flakes 配置文件
├── flake.lock               # Nix 依赖锁定文件
└── README.md                # 项目说明文档
```

## 🔧 环境要求

- **Nix** (推荐) 或 **Hugo** (直接安装)
- **Git**
- **GitHub 账户**（用于部署）
- **Obsidian**（可选，用于笔记写作）

## 📦 安装与设置

### 方式一：使用 Nix Flakes（推荐）

1. **安装 Nix 和启用 Flakes**

   ```bash
   # 如果尚未安装 Nix，请访问 https://nixos.org/download.html
   # 启用 Flakes 功能
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. **进入开发环境**

   ```bash
   nix develop
   ```

   这将自动安装 Hugo 和 Git，并进入开发环境。

### 方式二：直接安装 Hugo

1. **安装 Hugo**

   - macOS: `brew install hugo`
   - Linux: 参考 [Hugo 官方文档](https://gohugo.io/installation/)
   - Windows: 使用 Chocolatey `choco install hugo`

2. **克隆仓库**

   ```bash
   git clone <repository-url>
   cd hugo-server
   ```

## 🚀 使用方法

### 本地开发

1. **启动本地服务器**

   ```bash
   cd jesse-blog
   hugo server -D
   ```

   访问 `http://localhost:1313` 查看博客。

2. **创建新文章**

   ```bash
   hugo new posts/your-post-name.md
   ```

   编辑 `content/posts/your-post-name.md` 文件。

3. **预览草稿**

   使用 `-D` 参数可以预览草稿文章：

   ```bash
   hugo server -D
   ```

### 构建静态网站

```bash
cd jesse-blog
hugo -D  # 生成包含草稿的静态网站
```

生成的网站位于 `jesse-blog/public/` 目录。

## 🧠 Obsidian 集成指南

这个博客支持使用 Obsidian 进行笔记写作和发布工作流。以下是设置和使用方法：

### 1. 设置 Obsidian 仓库链接

1. 将 `jesse-blog/content` 目录设置为您的 Obsidian vault
2. 或者，创建一个符号链接将 Obsidian vault 指向 Hugo 的 content 目录

```bash
# 在 Obsidian vault 设置中，将 vault 设置为 jesse-blog/content 目录
# 或创建符号链接
ln -s /path/to/hugo-server/jesse-blog/content /path/to/your/obsidian/vault
```

### 2. Obsidian 配置

- 在 Obsidian 中安装有用的插件：
  - **Templater**：用于创建 Hugo 兼容的 frontmatter 模板
  - **Dataview**：用于动态内容查询
  - **Obsidian Publish**（可选）：如果使用 Obsidian 的发布功能

### 3. Frontmatter 模板

在 Obsidian 中创建一个模板，确保每篇笔记都包含必要的 Hugo frontmatter：

```
---
title: "{{title}}"
date: {{date:YYYY-MM-DDTHH:mm:ss+08:00}}
draft: true
tags: []
categories: []
---

```

### 4. 链接格式转换

请注意，Obsidian 使用 `[[Page Title]]` 格式的内部链接，而 Hugo 使用标准 Markdown 链接。您需要：
- 将 `[[Page Title]]` 转换为 `[Page Title](/path-to-page)` 
- 或使用 Hugo 的 `ref`/`relref` 链接语法

### 5. 工作流程

1. 在 Obsidian 中写笔记
2. 使用正确的 frontmatter 格式
3. 将笔记文件移动到 `content/posts/` 目录
4. 运行 `hugo server -D` 预览
5. 调整内容并发布

## 📤 部署

### 自动部署（推荐）

使用提供的部署脚本：

```bash
./deploy.sh
```

脚本将：

1. 生成静态网站到 `public/` 目录
2. 提交并推送到 GitHub Pages 仓库
3. 更新子模块引用

### 手动部署

1. **生成静态网站**

   ```bash
   cd jesse-blog
   hugo -D
   ```

2. **提交到 GitHub Pages**

   ```bash
   cd public
   git add .
   git commit -m "Deploy: $(date +%Y-%m-%d)"
   git push origin main
   ```

3. **更新主仓库**

   ```bash
   cd ..
   git add public
   git commit -m "Update submodule reference"
   git push origin main
   ```

## ⚙️ 配置说明

### Hugo 配置

主要配置文件：`jesse-blog/hugo.toml`

- `baseURL`: 网站基础 URL
- `languageCode`: 语言代码
- `title`: 网站标题
- `theme`: 使用的主题
- `params.defaultTheme`: 默认主题模式（light/dark/auto）

### 主题配置

主题位于 `jesse-blog/themes/hugo-PaperMod/`，可根据需要自定义。PaperMod 主题配置说明：

- `params.defaultTheme`: 默认主题模式（light/dark/auto）
- `params.showShareButtons`: 显示分享按钮
- `params.showReadingTime`: 显示阅读时间
- `params.showPostNavLinks`: 显示文章导航链接
- `params.showBreadCrumbs`: 显示面包屑导航
- `params.showCodeCopyButtons`: 显示代码复制按钮

## 📝 编写文章

文章使用 Markdown 格式，位于 `content/posts/` 目录。文章 Front Matter 示例：

```yaml
---
title: "文章标题"
date: 2025-02-26T12:00:00+08:00
draft: false
tags: ["标签1", "标签2"]
categories: ["分类"]
---
```

## 🔍 常用命令

```bash
# 启动开发服务器
hugo server -D

# 生成静态网站
hugo -D

# 创建新文章
hugo new posts/article-name.md

# 查看帮助
hugo help

# 搜索功能（如果启用）
# PaperMod 提供了搜索功能，在配置中启用后可以使用
```

## 📚 相关资源

- [Hugo 官方文档](https://gohugo.io/documentation/)
- [PaperMod 主题文档](https://adityatelange.github.io/hugo-PaperMod/)
- [Obsidian 官方网站](https://obsidian.md/)
- [Nix Flakes 文档](https://nixos.wiki/wiki/Flakes)
- [GitHub Pages 文档](https://docs.github.com/en/pages)

## 📚 相关资源

- [Hugo 官方文档](https://gohugo.io/documentation/)
- [Stack 主题文档](https://github.com/CaiJimmy/hugo-theme-stack)
- [Nix Flakes 文档](https://nixos.wiki/wiki/Flakes)
- [GitHub Pages 文档](https://docs.github.com/en/pages)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目为私有仓库，仅供个人使用。

---

**注意**：`public/` 目录是一个 Git 子模块，指向 GitHub Pages 仓库。请勿直接修改该目录中的文件，应通过 `hugo` 命令生成。

---

## 🚀 自动化部署工作流程（新）

### 概述

项目已升级为完全自动化的部署流程，解决了手动部署与 GitHub Actions 冲突的问题。

**工作流程：**
```
Obsidian 编辑 → Push 到 obsidian-notes → 自动触发 hugo-server → 构建并部署
```

### 快速开始

#### 1. 本地预览

```bash
# 基本预览
./dev.sh

# 局域网访问（其他设备查看）
./dev.sh 0.0.0.0

# 自定义 baseURL
./dev.sh 0.0.0.0 http://192.168.1.100:1313
```

#### 2. 发布内容

在 Obsidian 或 `jesse-blog/content` 目录编辑内容后：

```bash
cd jesse-blog/content
git add .
git commit -m "Add new post"
git push
```

✨ GitHub Actions 会自动构建并部署到 GitHub Pages！

#### 3. 修改主题/配置

```bash
# 1. 修改主题或配置文件
vim jesse-blog/hugo.toml

# 2. 本地预览效果
./dev.sh

# 3. 满意后提交
git add jesse-blog/
git commit -m "Update theme"
git push
```

✨ 自动触发构建和部署！

### 配置 GitHub Actions

**⚠️ 首次使用需要配置 GitHub Tokens**

详细步骤请参阅：[SETUP_GUIDE.md](./SETUP_GUIDE.md)

简要步骤：
1. 创建 GitHub Personal Access Token（需要 `repo` 和 `workflow` 权限）
2. 在 `hugo-server` 仓库添加 Secret: `PERSONAL_TOKEN`
3. 在 `obsidian-notes` 仓库添加 Secret: `HUGO_SERVER_TOKEN`
4. 在 `obsidian-notes` 部署触发器 workflow（见 `obsidian-notes-workflow.yml`）

### 优势

- ✅ **无冲突**：不再需要手动部署，避免 Git 冲突
- ✅ **自动化**：内容更新自动触发构建
- ✅ **灵活预览**：本地随时预览主题修改
- ✅ **多仓库同步**：内容、主题、部署完全分离

### 故障排查

如果遇到问题，请查看：
- GitHub Actions 日志：https://github.com/JiashuaiXu/hugo-server/actions
- 详细排查指南：[SETUP_GUIDE.md](./SETUP_GUIDE.md#故障排查)

### 回退到手动部署

如需临时使用手动部署：

```bash
./deploy.sh.backup
```

⚠️ 注意：手动部署可能与自动部署冲突！

---

## 📁 项目结构

```
hugo-server/
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions 自动部署
├── jesse-blog/                     # Hugo 站点目录
│   ├── content/                    # 内容目录（submodule: obsidian-notes）
│   ├── themes/                     # 主题目录
│   │   └── hugo-PaperMod/          # PaperMod 主题
│   ├── public/                     # 构建输出（submodule: JiashuaiXu.github.io）
│   └── hugo.toml                   # Hugo 配置文件
├── dev.sh                          # 本地预览脚本
├── deploy.sh                       # 已弃用提示
├── deploy.sh.backup                # 旧的手动部署脚本
├── obsidian-notes-workflow.yml     # obsidian-notes 的触发器配置
└── SETUP_GUIDE.md                  # 详细配置指南
```

---

**原有文档内容保留在上方**
