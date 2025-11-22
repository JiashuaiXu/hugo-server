# 功能6: 条件显示阅读进度条 (仅单页显示)

## 功能说明

修改阅读进度条的显示逻辑，使其只在单篇文章页面显示，不在首页等列表页面显示。

## 问题背景

原实现中，阅读进度条显示在所有页面上，包括首页。但在首页等列表页面显示进度条意义不大，用户体验不佳。

## 实现效果

- **单篇文章页面**: 显示阅读进度条，帮助用户追踪阅读进度
- **首页/列表页面**: 不显示阅读进度条，保持页面简洁
- **其他页面**: 不显示阅读进度条

## 配置步骤

### 1. 修改 extend_footer.html

更新 `jesse-blog/layouts/partials/extend_footer.html` 文件，添加条件判断：

```html
<!-- 阅读进度条 (仅在单页显示) -->
{{- if eq .Kind "page" }}
<div class="reading-progress-bar" id="reading-progress"></div>

<!-- 阅读进度条脚本 -->
<script>
  window.addEventListener('scroll', function() {
    const progressBar = document.getElementById('reading-progress');
    if (!progressBar) return;
    
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    
    const scrollPercent = (scrollTop / (documentHeight - windowHeight)) * 100;
    progressBar.style.width = Math.min(scrollPercent, 100) + '%';
  });
</script>
{{- end }}

<!-- 不蒜子访问统计 -->
<script async src="//busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>
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

### 2. Hugo 模板变量说明

- `.Kind` - Hugo 内置变量，表示页面类型
- `"page"` - 表示单个内容页面 (如单篇博客文章)
- `"home"` - 表示首页
- `"section"` - 表示内容区段页面

### 3. 测试验证

验证进度条只在特定页面类型显示：

- 首页 (`/`): 不显示进度条
- 文章页 (`/posts/article-name/`): 显示进度条
- 其他内容页: 根据 Kind 值决定是否显示

## 工作原理

1. Hugo 模板引擎根据 `.Kind` 变量判断当前页面类型
2. 只有当页面类型为 `"page"` 时才渲染进度条相关 HTML 和 JavaScript
3. 首页、列表页等其他类型页面不会包含进度条代码

## 优势

- **用户体验**: 避免在不必要页面显示进度条
- **页面简洁**: 首页等列表页面更加清爽
- **性能优化**: 不必要的页面不加载进度条相关代码
- **逻辑清晰**: 根据页面内容类型智能显示相关功能

## 回滚步骤

如需恢复到原来的全站显示进度条，请将 `extend_footer.html` 中的条件判断移除：

```html
<!-- 阅读进度条 -->
<div class="reading-progress-bar" id="reading-progress"></div>

<!-- 阅读进度条脚本 -->
<script>
  window.addEventListener('scroll', function() {
    const progressBar = document.getElementById('reading-progress');
    if (!progressBar) return;
    
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    
    const scrollPercent = (scrollTop / (documentHeight - windowHeight)) * 100;
    progressBar.style.width = Math.min(scrollPercent, 100) + '%';
  });
</script>
```

## 相关文档

- [功能2: 顶部阅读进度条](./02-reading-progress-bar.md) - 原始实现方案
- [Hugo Page Kinds](https://gohugo.io/templates/section-templates/#page-kinds) - Hugo 官方文档