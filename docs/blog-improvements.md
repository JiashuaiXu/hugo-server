# Hugo 博客改进方案总结

本文档记录了对 Hugo PaperMod 主题博客的一系列改进和优化。

## 目录
1. [文章元信息优化](#1-文章元信息优化)
2. [侧边目录(TOC)实现](#2-侧边目录toc实现)
3. [访问统计国际化](#3-访问统计国际化)
4. [日期格式优化](#4-日期格式优化)
5. [GitHub Actions优化](#5-github-actions优化)

---

## 1. 文章元信息优化

### 问题描述
- 原始文章元信息位置不当，放在页脚不符合阅读习惯
- "4 min" 含义不明确
- 缺少字数统计

### 解决方案

#### 1.1 调整元信息位置
**文件**: `layouts/_default/single.html`

将 `post-meta` 从 `<footer>` 移到 `<header>` 中：

```html
<header class="post-header">
  <h1 class="post-title">{{ .Title }}</h1>
  {{- if not (.Param "hideMeta") }}
  <div class="post-meta">
    {{- partial "post_meta.html" . -}}
  </div>
  {{- end }}
</header>
```

#### 1.2 添加字数统计和Emoji图标
**文件**: `layouts/partials/post_meta.html`

```html
{{- if (.Param "ShowReadingTime") -}}
{{- $scratch.Add "meta" (slice (printf "<span>⏱️ %d min read</span>" .ReadingTime)) }}
{{- end }}

{{- if (.Param "ShowWordCount") -}}
{{- $scratch.Add "meta" (slice (printf "<span>📝 %d words</span>" .WordCount)) }}
{{- end }}
```

#### 1.3 启用字数统计
**文件**: `hugo.toml`

```toml
[params]
  ShowWordCount = true
```

### 最终效果
```
📅 2025-11-18 · ⏱️ 4 min read · 📝 1200 words · ✍️ Jesse · 👁️ 116 views
```

### 使用的Emoji
- 📅 日期
- ⏱️ 阅读时长
- 📝 字数
- ✍️ 作者
- 👁️ 阅读量

---

## 2. 侧边目录(TOC)实现

### 问题描述
- 原始TOC布局遮挡文章内容
- 需要缩放页面才能触发侧边显示
- 选中目录项不够明显

### 解决方案

参考: [周鑫的博客](https://www.zhouxin.space/logs/introduce-side-toc-and-reading-percentage-to-papermod/)

#### 2.1 创建TOC模板
**文件**: `layouts/partials/toc.html`

**关键功能**:
1. HTML结构生成：解析文章标题，生成多级目录
2. 自动高亮：滚动时高亮当前章节
3. 自动滚动：TOC自动滚动保持活动链接可见
4. 响应式检测：根据屏幕宽度切换侧边/内联模式

**触发阈值**: 1000px（宽度≥1000px时显示侧边TOC）

#### 2.2 创建TOC样式
**文件**: `assets/css/extended/toc.css`

**CSS变量**:
```css
:root {
  --article-width: 650px;
  --toc-width: 300px;
}
```

**布局策略**:

宽屏模式（≥1000px）:
```css
.toc-container.wide {
  position: absolute;
  left: calc((var(--toc-width) + var(--gap)) * -1);
  /* TOC定位在文章左侧 */
}

.wide .toc {
  position: sticky;
  top: var(--gap);
  /* TOC内容粘性定位，跟随滚动 */
}
```

小屏模式（<1000px）:
```css
@media screen and (max-width: 1000px) {
  .toc-container.wide {
    position: relative;
    /* 切换为正常文档流 */
  }
}
```

#### 2.3 增强选中样式
**选中目录的视觉效果**:
```css
.active {
  font-size: 110%;
  font-weight: 700;
  color: var(--primary) !important;
  border-left: 3px solid var(--primary);
  padding-left: 12px !important;
  background: var(--theme);
  border-radius: 4px;
}
```

### 实现效果
- ✅ 在宽屏（≥1000px）时，TOC显示在文章左侧
- ✅ 阅读时自动高亮当前章节
- ✅ TOC自动滚动，保持当前章节可见
- ✅ 小屏幕时自动切换为内联显示
- ✅ 选中目录项有明显的颜色和边框标识

---

## 3. 访问统计国际化

### 问题描述
访问统计信息使用中文，与整体英文风格不一致。

### 解决方案

#### 3.1 单篇文章阅读数
**文件**: `layouts/partials/post_meta.html`

```html
<span id="busuanzi_container_page_pv" class="post-views">
  &nbsp;·&nbsp;👁️ <span id="busuanzi_value_page_pv"></span> views
</span>
```

#### 3.2 网站全局统计
**文件**: `layouts/partials/extend_footer.html`

```html
<div class="site-stats">
  <span id="busuanzi_container_site_pv">
    <span id="busuanzi_value_site_pv"></span> total views
  </span>
  <span class="footer-separator"> · </span>
  <span id="busuanzi_container_site_uv">
    <span id="busuanzi_value_site_uv"></span> visitors
  </span>
</div>
```

#### 3.3 统一样式
**文件**: `assets/css/extended/custom.css`

```css
.site-stats {
  text-align: center;
  font-size: 14px;
  color: var(--secondary);
  padding: 10px 0;
  opacity: 0.8;
}
```

### 对比效果

| 位置 | 修改前 | 修改后 |
|------|--------|--------|
| 文章页 | 阅读 110 次 | 👁️ 110 views |
| 页脚 | 总访问量 104 次 \| 访客数 18 人 | 104 total views · 18 visitors |

---

## 4. 日期格式优化

### 问题描述
日期格式使用 "November 18, 2025" 过长，不够简洁。

### 解决方案
**文件**: `hugo.toml`

```toml
[params]
  DateFormat = "2006-01-02"
```

**说明**: `2006-01-02` 是 Go 语言的时间格式标准模板。

### 对比效果
- **修改前**: November 18, 2025
- **修改后**: 2025-11-18

更加简洁，符合 ISO 8601 标准。

---

## 5. GitHub Actions优化

### 问题描述
部署流水线在 "Update content submodule" 步骤卡住，无限等待。

### 问题原因
- `git submodule update --remote` 可能因网络问题或权限问题一直等待
- 没有超时限制

### 解决方案
**文件**: `.github/workflows/deploy.yml`

#### 5.1 添加超时限制
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 10
```

#### 5.2 简化submodule更新
```yaml
- name: Update content submodule
  run: |
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
    git config --global user.name "github-actions[bot]"
    cd jesse-blog/content
    git pull origin main || echo "Content submodule update skipped"
    cd ../..
  continue-on-error: true
```

#### 5.3 关键改进
- 使用 `git pull` 代替 `git submodule update --remote`
- 添加 `continue-on-error: true`，即使submodule更新失败也继续部署
- 添加错误处理 `|| echo`

---

## 配置文件总览

### 必需文件

```
hugo-server/
├── jesse-blog/
│   ├── layouts/
│   │   ├── _default/
│   │   │   └── single.html          # 文章模板
│   │   └── partials/
│   │       ├── post_meta.html        # 元信息显示
│   │       ├── extend_footer.html    # 页脚扩展
│   │       └── toc.html              # 侧边目录
│   ├── assets/
│   │   └── css/
│   │       └── extended/
│   │           ├── toc.css           # TOC样式
│   │           └── custom.css        # 自定义样式
│   └── hugo.toml                     # Hugo配置
└── .github/
    └── workflows/
        └── deploy.yml                # 部署流水线
```

### 关键配置

**hugo.toml**:
```toml
[params]
  DateFormat = "2006-01-02"
  ShowWordCount = true
  ShowReadingTime = true
  ShowToc = true
  TocOpen = true
```

---

## 浏览器缓存清理

部署后如果看不到效果，需要强制刷新：

- **Chrome/Edge**: `Ctrl + Shift + R` (Windows) / `Cmd + Shift + R` (Mac)
- **Firefox**: `Ctrl + F5` (Windows) / `Cmd + Shift + R` (Mac)
- 或使用开发者工具的"清空缓存并硬性重新加载"

---

## 总结

通过以上改进，博客实现了：

1. ✅ 更直观的文章元信息展示（emoji + 字数统计）
2. ✅ 优雅的侧边目录（自动高亮、响应式）
3. ✅ 统一的英文界面风格
4. ✅ 简洁的日期格式（ISO 8601）
5. ✅ 稳定的自动部署流程

所有修改都遵循以下原则：
- 🎨 **视觉优先**: 使用emoji和现代化设计
- 🌍 **国际化**: 统一使用英文
- 📱 **响应式**: 适配各种屏幕尺寸
- ⚡ **性能**: 优化部署流程
- 📚 **可维护**: 清晰的代码结构和文档

---

## 参考资源

- [Hugo PaperMod 主题](https://github.com/adityatelange/hugo-PaperMod)
- [周鑫的博客 - 侧边TOC实现](https://www.zhouxin.space/logs/introduce-side-toc-and-reading-percentage-to-papermod/)
- [Hugo 官方文档](https://gohugo.io/documentation/)
- [不蒜子统计](https://busuanzi.ibruce.info/)

---

**最后更新**: 2025-11-19
**维护者**: Jesse

---

## 6. 列表页Emoji优化

### 问题描述
在首页和归档页等列表页面，每篇文章都显示emoji图标会使页面显得凌乱，影响阅读体验。

### 解决方案

**文件**: `layouts/partials/post_meta.html`

使用 Hugo 的上下文检测，根据页面类型自动决定是否显示emoji：

```go
{{- $isSingle := .IsPage }}

{{- if not .Date.IsZero -}}
{{- if $isSingle -}}
  {{- /* 详情页：显示emoji */ -}}
  {{- $scratch.Add "meta" (slice (printf "<span>📅 %s</span>" (.Date | time.Format))) }}
{{- else -}}
  {{- /* 列表页：不显示emoji */ -}}
  {{- $scratch.Add "meta" (slice (printf "<span>%s</span>" (.Date | time.Format))) }}
{{- end -}}
{{- end }}
```

### 效果对比

**文章详情页**（点开文章后）：
```
📅 2025-11-18 · ⏱️ 4 min read · 📝 1200 words · ✍️ Jesse · 👁️ 116 views
```

**列表页/首页**（文章缩略）：
```
2025-11-18 · 4 min read · 1200 words · Jesse · 116 views
```

### 优势
1. ✅ **列表页简洁清爽**：去除emoji，信息更紧凑
2. ✅ **详情页突出重点**：emoji增加视觉吸引力
3. ✅ **自动适配**：无需额外配置，根据页面类型自动切换
4. ✅ **统一管理**：一个模板文件处理两种情况

---

**最后更新**: 2025-11-19  
**版本**: v2.0

---

## 7. 列表页显示标签

### 问题描述
在列表页/首页的缩略框中，仅显示日期、字数等信息，缺乏文章内容的分类标识（Tag），用户无法快速了解文章主题。

### 解决方案

**文件**: `layouts/partials/post_meta.html`

在列表页模式下（`if not $isSingle`），检测文章是否有标签，如果有则显示前3个标签：

```go
{{- /* 在列表页显示标签 */ -}}
{{- if not $isSingle -}}
  {{- with .Params.tags -}}
    {{- /* 获取前3个标签，避免显示太多 */ -}}
    {{- $tags := first 3 . -}}
    {{- $tagStr := delimit $tags ", " -}}
    {{- $scratch.Add "meta" (slice (printf "<span>🏷️ %s</span>" $tagStr)) }}
  {{- end -}}
{{- end -}}
```

### 效果对比

**列表页/首页**：
```
2025-11-18 · 4 min read · 1200 words · Jesse · 🏷️ hugo, blog, tutorial · views
```

### 优势
1. ✅ **内容标识**：用户可以直接在列表页看到文章标签
2. ✅ **视觉平衡**：限制显示前3个标签，防止元信息过长
3. ✅ **统一风格**：使用 🏷️ 图标，与其他元信息风格保持一致

---

**最后更新**: 2025-11-20  
**版本**: v2.1
