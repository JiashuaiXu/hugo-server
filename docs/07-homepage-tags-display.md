# 功能7: 首页标签显示优化

## 功能说明

在首页（文章列表）上优先显示文章标签，而不是详细的带emoji元信息，以提升首页浏览体验。标签使用美观的矩形样式呈现。

## 问题背景

原实现中，首页和单页都显示相同的元信息格式，包含emoji和详细信息，导致：
- 首页信息过于冗长
- 标签信息不突出
- 用户浏览效率低

## 实现效果

### 首页（列表页面）
- 优先显示文章标签，以美观的矩形样式呈现 (`🏷️ 标签1, 标签2, 标签3`)
- 简化元信息（仅显示日期）
- 不显示阅读时间和字数的emoji
- 标签具有梯度背景、圆角矩形和悬停效果

### 单页（详情页面）
- 保持原有的丰富元信息显示
- 包含日期、阅读时间、字数、作者等完整信息
- 使用emoji增强视觉效果

## 配置步骤

### 1. 创建自定义列表模板

创建文件 `jesse-blog/layouts/_default/list.html`:

```html
<!-- 在 entry-footer 部分调用 post_meta 时传递列表项标识 -->
<footer class="entry-footer">
  {{- partial "post_meta.html" (dict "page" . "isListItem" true) -}}
</footer>
```

### 2. 修改 post_meta.html 部分

更新 `jesse-blog/layouts/partials/post_meta.html` 以支持上下文区分：

```html
{{- $scratch := newScratch }}

{{- /* 判断是否从列表项调用 */ -}}
{{- $ctx := . -}}
{{- $isListItem := false -}}
{{- if reflect.IsMap . -}}
  {{- $ctx = .page -}}
  {{- $isListItem = .isListItem | default false -}}
{{- end -}}

{{- /* 在列表页显示标签为主要内容 */ -}}
{{- if $isListItem -}}
  {{- $metaItems := slice -}}
  
  {{- /* 优先显示标签 */ -}}
  {{- with $ctx.Params.tags -}}
    {{- $tags := first 3 . -}}
    {{- $tagStr := delimit $tags ", " -}}
    {{- $metaItems = $metaItems | append (printf "<span class='post-tags'>🏷️ %s</span>" $tagStr) }}
  {{- end -}}
  
  {{- /* 显示日期作为基本元信息 */ -}}
  {{- if not $ctx.Date.IsZero -}}
    {{- $metaItems = $metaItems | append (printf "<span class='post-date' title='%s'>%s</span>" ($ctx.Date) ($ctx.Date | time.Format (default "2006-01-02" site.Params.DateFormat))) }}
  {{- end -}}

  {{- $scratch.Set "meta" $metaItems -}}

{{- /* 在单页显示详细元信息 */ -}}
{{- else -}}
  {{- $metaItems := slice -}}
  {{- if not $ctx.Date.IsZero -}}
    {{- $metaItems = $metaItems | append (printf "<span title='%s'>📅 %s</span>" ($ctx.Date) ($ctx.Date | time.Format (default "2006-01-02" site.Params.DateFormat))) }}
  {{- end }}

  {{- if ($ctx.Param "ShowReadingTime") -}}
    {{- $metaItems = $metaItems | append (printf "<span>⏱️ %d min read</span>" $ctx.ReadingTime) }}
  {{- end }}

  {{- if ($ctx.Param "ShowWordCount") -}}
    {{- $metaItems = $metaItems | append (printf "<span>📝 %d words</span>" $ctx.WordCount) }}
  {{- end }}

  {{- if not ($ctx.Param "hideAuthor") -}}
    {{- with (partial "author.html" $ctx) }}
      {{- $metaItems = $metaItems | append (printf "<span>✍️ %s</span>" .) }}
    {{- end }}
  {{- end }}
  
  {{- $scratch.Set "meta" $metaItems -}}
{{- end -}}

{{- with ($scratch.Get "meta") }}
{{- delimit . "&nbsp;·&nbsp;" | safeHTML -}}
{{- end -}}

<!-- 阅读数显示逻辑保持一致 -->
{{- if not $isListItem -}}
<span id="busuanzi_container_page_pv" class="post-views">
  &nbsp;·&nbsp;👁️ <span id="busuanzi_value_page_pv"></span> views
</span>
{{- else -}}
<span id="busuanzi_container_page_pv" class="post-views">
  &nbsp;·&nbsp;<span id="busuanzi_value_page_pv"></span> views
</span>
{{- end -}}
```

## 最终效果

### 首页显示
```
🏷️ 测试, 自动化, GitHub Actions · 2025-11-20
```

### 单页显示
```
📅 2025-11-20 · ⏱️ 4 min read · 📝 1200 words · ✍️ Jesse · 👁️ 116 views
```

## 优势

- **提升首页浏览效率**: 标签作为内容分类快速入口
- **信息层次清晰**: 首页简洁，详情页丰富
- **用户体验优化**: 针对不同页面场景优化信息展示
- **向后兼容**: 不影响现有单页显示效果
- **美观的标签样式**: 矩形标签带渐变背景和悬停效果

## 样式配置

### 3. 添加标签样式

更新 `jesse-blog/layouts/partials/extend_head.html` 以添加标签样式：

```html
<!-- 首页标签样式 -->
<style>
  /* 首页标签样式 - 仅在列表页面应用 */
  .post-entry .post-tags {
    display: inline-block;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 3px 10px;
    border-radius: 16px;
    font-size: 0.85em;
    margin-right: 5px;
    border: none;
    text-decoration: none;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    transition: all 0.2s ease;
  }
  
  .post-entry .post-tags:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    text-decoration: none;
  }
  
  /* 为深色主题提供样式 */
  html[data-theme="dark"] .post-entry .post-tags {
    background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
  }
</style>
```

## 注意事项

- 需要给文章添加 `tags` front matter 才能显示标签
- 标签最多显示前3个，避免标签过多影响布局
- 使用 `reflect.IsMap` 检测参数类型以支持两种调用方式
- 样式包括圆角矩形、渐变背景、悬停效果等视觉增强