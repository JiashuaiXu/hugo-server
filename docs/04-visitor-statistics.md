# 功能4: 访问统计功能

## 功能说明

使用不蒜子(busuanzi)统计服务,在博客中显示访问数据。

## 实现效果

### 博客总访问量(页面底部)
- 总访问量 (PV - Page Views)
- 访客数 (UV - Unique Visitors)
- 显示在每个页面的底部

### 单篇文章阅读数
- 显示在文章标题下方的元数据区域
- 与发布日期、阅读时间等信息一起显示

## 配置步骤

### 1. 在 extend_footer.html 中添加不蒜子脚本

编辑 `jesse-blog/layouts/partials/extend_footer.html`,添加:

```html
<!-- 不蒜子访问统计 -->
<script async src="//busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>
<div style="text-align: center; padding: 20px 0; color: var(--secondary);">
  <span id="busuanzi_container_site_pv" style="display: inline-block; margin: 0 10px;">
    总访问量 <span id="busuanzi_value_site_pv"></span> 次
  </span>
  <span style="margin: 0 5px;">|</span>
  <span id="busuanzi_container_site_uv" style="display: inline-block; margin: 0 10px;">
    访客数 <span id="busuanzi_value_site_uv"></span> 人
  </span>
</div>
```

### 2. 创建自定义 post_meta.html

创建文件 `jesse-blog/layouts/partials/post_meta.html`:

```html
{{- $scratch := newScratch }}

{{- if not .Date.IsZero -}}
{{- $scratch.Add "meta" (slice (printf "<span title='%s'>%s</span>" (.Date) (.Date | time.Format (default "January 2, 2006" site.Params.DateFormat)))) }}
{{- end }}

{{- if (.Param "ShowReadingTime") -}}
{{- $scratch.Add "meta" (slice (i18n "read_time" .ReadingTime | default (printf "%d min" .ReadingTime))) }}
{{- end }}

{{- if (.Param "ShowWordCount") -}}
{{- $scratch.Add "meta" (slice (i18n "words" .WordCount | default (printf "%d words" .WordCount))) }}
{{- end }}

{{- with (partial "author.html" .) }}
{{- $scratch.Add "meta" (slice .) }}
{{- end }}

{{- with ($scratch.Get "meta") }}
{{- delimit . "&nbsp;·&nbsp;" -}}
{{- end -}}

<!-- 单篇文章阅读数 -->
<span id="busuanzi_container_page_pv" style="display: inline;">
  &nbsp;·&nbsp;阅读 <span id="busuanzi_value_page_pv"></span> 次
</span>
```

## 自定义样式

### 调整底部统计样式

可以在 `jesse-blog/assets/css/extended/custom.css` 中添加:

```css
/* 文章统计样式 */
.post-stats {
  text-align: center;
  padding: 15px 0;
  margin-top: 20px;
  border-top: 1px solid var(--border);
  color: var(--secondary);
  font-size: 14px;
}

.post-stats span {
  display: inline-block;
  margin: 0 10px;
}

/* 底部统计容器样式 */
#busuanzi_container_site_pv,
#busuanzi_container_site_uv {
  font-size: 14px;
}
```

### 修改显示文本

在 `extend_footer.html` 中修改文本:

```html
<span id="busuanzi_container_site_pv">
  本站访问量 <span id="busuanzi_value_site_pv"></span>
</span>
<span id="busuanzi_container_site_uv">
  访客数 <span id="busuanzi_value_site_uv"></span>
</span>
```

在 `post_meta.html` 中修改:

```html
<span id="busuanzi_container_page_pv">
  &nbsp;·&nbsp;浏览 <span id="busuanzi_value_page_pv"></span>
</span>
```

## 移除步骤

### 移除博客总访问量

从 `jesse-blog/layouts/partials/extend_footer.html` 中删除:
- 不蒜子 `<script>` 标签
- 统计显示的 `<div>` 部分

### 移除单篇文章阅读数

方法1: 删除整个自定义文件(恢复主题默认):
```bash
rm jesse-blog/layouts/partials/post_meta.html
```

方法2: 只删除统计部分,保留其他元数据:
从 `post_meta.html` 中删除:
```html
<!-- 单篇文章阅读数 -->
<span id="busuanzi_container_page_pv" style="display: inline;">
  &nbsp;·&nbsp;阅读 <span id="busuanzi_value_page_pv"></span> 次
</span>
```

## 工作原理

1. 加载不蒜子的 JavaScript 脚本
2. 脚本根据 URL 自动统计访问量
3. 将统计数据注入到特定 ID 的 HTML 元素中:
   - `busuanzi_value_site_pv`: 站点总访问量
   - `busuanzi_value_site_uv`: 站点访客数
   - `busuanzi_value_page_pv`: 单页访问量

## 注意事项

1. **本地开发**: 
   - 本地开发时统计数据不准确或显示为 0
   - 部署到生产环境后才会正常工作

2. **首次加载**:
   - 页面首次加载时可能需要 1-2 秒显示统计数据
   - 使用 `async` 加载脚本不会阻塞页面渲染

3. **隐私问题**:
   - 不蒜子是第三方服务,会记录访问信息
   - 如果需要更高隐私保护,可以考虑自托管的替代方案

4. **备用方案**:
   如不使用不蒜子,可以选择:
   - Google Analytics
   - umami (开源自托管)
   - Plausible (注重隐私)
   - Cloudflare Analytics

## 故障排除

### 统计数据不显示

1. 检查浏览器控制台是否有脚本加载错误
2. 确保网络可以访问 `busuanzi.ibruce.info`
3. 检查 HTML 元素的 ID 是否正确

### 统计数据异常

1. 清除浏览器缓存
2. 检查是否有广告拦截插件拦截了统计脚本
3. 部分地区可能无法访问不蒜子服务

### 调试方法

在浏览器控制台运行:

```javascript
console.log(document.getElementById('busuanzi_value_site_pv'));
console.log(document.getElementById('busuanzi_value_site_uv'));
console.log(document.getElementById('busuanzi_value_page_pv'));
```

检查这些元素是否存在并包含数据。

## 替代方案: Google Analytics

如需使用 Google Analytics 代替不蒜子:

1. 在 `hugo.toml` 中配置:
```toml
[services]
  [services.googleAnalytics]
    ID = "G-XXXXXXXXXX"  # 你的 GA4 ID
```

2. 确保 `layouts/partials/google_analytics.html` 存在并包含:
```html
{{- if site.Config.Services.GoogleAnalytics.ID }}
{{- template "_internal/google_analytics.html" . }}
{{- end }}
```

注意: Google Analytics 不会在页面上直接显示数据,需要到 GA 后台查看。
