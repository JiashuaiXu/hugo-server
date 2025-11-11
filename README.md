# Hugo Blog Server

一个基于 [Hugo](https://gohugo.io/) 静态网站生成器构建的个人博客项目，使用 [Stack 主题](https://github.com/CaiJimmy/hugo-theme-stack)，并通过 Nix Flakes 管理开发环境。

## 📋 项目简介

这是一个私有 GitHub 仓库，用于安全地存储博客源代码和配置。生成的静态网站通过 `public/` 目录关联到公开仓库 [JiashuaiXu.github.io](https://github.com/JiashuaiXu/JiashuaiXu.github.io)，用于 GitHub Pages 部署。

## ✨ 功能特性

- 🚀 **快速部署**：一键部署脚本，自动生成并推送到 GitHub Pages
- 🎨 **现代主题**：使用 Hugo Stack 主题，支持亮色/暗色模式自动切换
- 🔧 **环境管理**：通过 Nix Flakes 提供可复现的开发环境
- 📝 **Markdown 支持**：使用 Markdown 编写博客文章
- 🌐 **多语言支持**：可配置多语言内容
- 📱 **响应式设计**：适配各种设备屏幕

## 🛠️ 技术栈

- **静态网站生成器**：Hugo
- **主题**：hugo-theme-stack
- **环境管理**：Nix Flakes
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
│   │   └── hugo-theme-stack/ # Stack 主题
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

主题位于 `jesse-blog/themes/hugo-theme-stack/`，可根据需要自定义。

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
```

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
