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

## 第五步：实现评论模板

创建 `jesse-blog/themes/hugo-PaperMod/layouts/partials/comments.html` 文件：

```html
{{- /* Comments area start */ -}}
{{- if .Site.Params.comments.enabled -}}
<div id="comments-section" style="margin-top: 2rem;">
  {{- if eq .Site.Params.comments.provider "giscus" -}}
  <script src="https://giscus.app/client.js"
          data-repo="{{ .Site.Params.comments.giscus.repo }}"
          data-repo-id="{{ .Site.Params.comments.giscus.repoId }}"
          data-category="{{ .Site.Params.comments.giscus.category }}"
          data-category-id="{{ .Site.Params.comments.giscus.categoryId }}"
          data-mapping="{{ .Site.Params.comments.giscus.mapping | default "pathname" }}"
          data-strict="{{ .Site.Params.comments.giscus.strict | default "0" }}"
          data-reactions-enabled="{{ .Site.Params.comments.giscus.reactionsEnabled | default "1" }}"
          data-emit-metadata="{{ .Site.Params.comments.giscus.emitMetadata | default "0" }}"
          data-input-position="{{ .Site.Params.comments.giscus.inputPosition | default "bottom" }}"
          data-theme="{{ .Site.Params.comments.giscus.theme | default "preferred_color_scheme" }}"
          data-lang="{{ .Site.Params.comments.giscus.lang | default "zh-CN" }}"
          data-loading="{{ .Site.Params.comments.giscus.loading | default "lazy" }}"
          crossorigin="anonymous"
          async>
  </script>
  {{- end -}}>
</div>
{{- end -}}
{{- /* Comments area end */ -}}
```

## 第六步：修改主题模板支持全局评论

修改 `jesse-blog/themes/hugo-PaperMod/layouts/_default/single.html`，将评论判断逻辑从：

```go
{{- if (.Param "comments") }}
{{- partial "comments.html" . }}
{{- end }}
```

改为：

```go
{{- if (or (.Param "comments") .Site.Params.comments.enabled) }}
{{- partial "comments.html" . }}
{{- end }}
```

这样可以：
- 如果全局启用评论（`params.comments.enabled = true`），所有文章默认显示评论
- 单篇文章可以通过 front matter 中的 `comments: false` 禁用评论
- 或者通过 `comments: true` 单独启用评论

## 验证配置

1. 构建站点：
```bash
cd jesse-blog
hugo
```

2. 检查生成的 HTML 是否包含 giscus 脚本：
```bash
grep -r "giscus.app/client.js" public/posts/ | head -3
```

3. 启动开发服务器测试：
```bash
hugo server -D
```

访问任意文章页面，应该能在文章底部看到 giscus 评论区。

## 配置说明

- **data-theme**: 使用 `preferred_color_scheme` 可以自动适配用户的系统主题（暗色/亮色）
- **data-mapping**: 使用 `pathname` 意味着每个 URL 路径对应一个独立的讨论话题
- **data-lang**: 设置为 `zh-CN` 显示中文界面

## 故障排除

如果评论不显示：
1. 确认 GitHub Discussions 已启用
2. 确认 Giscus App 已安装到仓库
3. 确认 `repoId` 和 `categoryId` 正确填写
4. 确认仓库是公开的
5. 检查浏览器控制台是否有错误信息
6. 确认 `comments.html` 模板文件已创建且内容正确
7. 确认 `single.html` 已修改以支持全局评论配置
