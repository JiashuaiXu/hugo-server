# Giscus 评论系统配置指南

## 什么是 Giscus？

Giscus 是基于 GitHub Discussions 的评论系统，具有以下优点：

- ✅ 完全免费和开源
- ✅ 无需数据库，评论存储在 GitHub Discussions
- ✅ 支持 Markdown 和代码高亮
- ✅ 支持多种主题，自动适配暗黑模式
- ✅ 支持 emoji reactions
- ✅ 无广告，无跟踪

## 配置步骤

### 1. 启用 GitHub Discussions

1. 访问仓库：https://github.com/JiashuaiXu/hugo-server
2. 进入 **Settings** → **General**
3. 找到 **Features** 部分
4. 勾选 **Discussions**

### 2. 安装 Giscus App

1. 访问：https://github.com/apps/giscus
2. 点击 **Install**
3. 选择 **Only select repositories**
4. 选择 `JiashuaiXu/hugo-server`
5. 点击 **Install**

### 3. 获取配置参数

1. 访问：https://giscus.app/zh-CN
2. 在 **配置** 部分填写：
   - **仓库**: `JiashuaiXu/hugo-server`
   - **页面 ↔️ discussion 映射关系**: pathname
   - **Discussion 分类**: Announcements (或创建新的分类如 "Comments")
3. 向下滚动到 **启用 giscus** 部分
4. 复制生成的配置参数，特别是：
   - `data-repo-id`
   - `data-category-id`

### 4. 更新 Hugo 配置

编辑 `jesse-blog/hugo.toml`，更新以下字段：

```toml
[params.comments.giscus]
  repo = "JiashuaiXu/hugo-server"
  repoId = "这里填写 data-repo-id"
  category = "Announcements"
  categoryId = "这里填写 data-category-id"
  # 其他配置保持不变
```

### 5. 测试评论系统

```bash
# 本地预览
./dev.sh

# 或使用 NixOS
nix develop
cd jesse-blog && hugo server -D
```

访问任意文章页面，应该能看到评论区域。

## 配置说明

### 当前配置

```toml
[params.comments]
  enabled = true              # 启用评论系统
  provider = "giscus"         # 使用 giscus

[params.comments.giscus]
  repo = "JiashuaiXu/hugo-server"
  repoId = ""                 # ⚠️ 需要填写
  category = "Announcements"
  categoryId = ""             # ⚠️ 需要填写
  mapping = "pathname"        # 使用页面路径映射
  strict = "0"                # 不严格匹配
  reactionsEnabled = "1"      # 启用 emoji reactions
  emitMetadata = "0"
  inputPosition = "bottom"    # 评论框在底部
  theme = "preferred_color_scheme"  # 自动适配暗黑/亮色模式
  lang = "zh-CN"              # 中文界面
  loading = "lazy"            # 延迟加载
```

### 主题选项

- `preferred_color_scheme` - 自动适配（推荐）
- `light` - 始终亮色
- `dark` - 始终暗色
- `dark_dimmed` - 柔和暗色
- `transparent_dark` - 透明暗色

### 映射方式

- `pathname` - 使用页面路径（推荐，当前配置）
- `url` - 使用完整 URL
- `title` - 使用页面标题
- `og:title` - 使用 Open Graph 标题

## 禁用评论

### 全局禁用

编辑 `jesse-blog/hugo.toml`：

```toml
[params.comments]
  enabled = false
```

### 单篇文章禁用

在文章的 Front Matter 中添加：

```yaml
---
title: "文章标题"
comments: false
---
```

## 自定义样式

如果需要自定义评论区样式，创建：

```
jesse-blog/layouts/partials/comments.html
```

并覆盖主题的默认模板。

## 管理评论

所有评论存储在 GitHub Discussions 中：

访问：https://github.com/JiashuaiXu/hugo-server/discussions

你可以：
- 📝 回复评论
- 🗑️ 删除不当评论
- 📌 置顶重要讨论
- 🔒 锁定讨论
- 🏷️ 添加标签

## 故障排查

### 问题 1：评论区不显示

**检查**：
1. Discussions 是否已启用
2. Giscus App 是否已安装
3. `repoId` 和 `categoryId` 是否正确填写
4. 仓库是否为公开状态

### 问题 2：无法发表评论

**可能原因**：
1. 用户未登录 GitHub
2. 用户没有仓库访问权限（需要公开仓库）
3. Discussions 被禁用

### 问题 3：主题不匹配

**解决**：
- 改用 `preferred_color_scheme` 自动适配
- 或手动设置 `theme = "dark"` 或 `theme = "light"`

## 替代方案

如果不想使用 giscus，PaperMod 还支持：

### Disqus

```toml
[params]
  disqusShortname = "your-disqus-shortname"
```

### Utterances

类似 giscus，基于 GitHub Issues：

```toml
[params.comments]
  enabled = true
  provider = "utterances"
  
[params.comments.utterances]
  repo = "JiashuaiXu/hugo-server"
  issueTerm = "pathname"
  theme = "github-dark"
```

### Commento

自托管评论系统：

```toml
[params]
  commentoURL = "https://commento.example.com"
```

## 隐私说明

使用 giscus 时：
- 评论者需要 GitHub 账号
- 评论内容存储在 GitHub（公开）
- 不会收集额外的用户数据
- 符合 GDPR 要求

## 参考资源

- **Giscus 官网**: https://giscus.app
- **Giscus GitHub**: https://github.com/giscus/giscus
- **PaperMod 文档**: https://github.com/adityatelange/hugo-PaperMod/wiki/Features#comments

---

**配置完成后**，记得提交更改并推送到 GitHub，触发自动部署！

```bash
git add jesse-blog/hugo.toml
git commit -m "Config: Enable giscus comment system"
git push
```
