# Hugo PaperMod 侧边目录（TOC）实现指南

## 概述

本文档记录了如何在 Hugo PaperMod 主题中实现侧边目录（Table of Contents）功能，包括自动高亮、滚动定位和响应式布局。

参考方案来源：[周鑫的个人博客](https://www.zhouxin.space/logs/introduce-side-toc-and-reading-percentage-to-papermod/)

## 实现效果

- ✅ 在宽屏（≥1200px）时，TOC显示在文章左侧，不遮挡内容
- ✅ 阅读时自动高亮当前章节
- ✅ TOC自动滚动，保持当前章节可见
- ✅ 小屏幕时自动切换为内联显示
- ✅ 支持长目录的滚动浏览

## 文件结构

需要创建/修改以下文件：

```
hugo-server/
├── jesse-blog/
│   ├── layouts/
│   │   ├── _default/
│   │   │   └── single.html          # 自定义文章模板（可选）
│   │   └── partials/
│   │       └── toc.html              # TOC HTML结构和JavaScript
│   └── assets/
│       └── css/
│           └── extended/
│               ├── toc.css           # TOC样式
│               └── custom.css        # 其他自定义样式
```

## 实现步骤

### 1. 创建 TOC 模板文件

创建 `layouts/partials/toc.html`，覆盖主题默认的TOC实现：

**关键点：**
- 使用 `<aside id="toc-container" class="toc-container wide">` 包裹TOC
- 添加JavaScript实现自动高亮和滚动
- 响应式检测，根据屏幕宽度切换布局模式

**主要功能：**
1. **HTML结构生成**：解析文章标题，生成多级目录
2. **自动高亮**：滚动时高亮当前阅读的章节
3. **自动滚动**：TOC自动滚动保持活动链接可见
4. **响应式检测**：根据屏幕宽度自动切换侧边/内联模式

### 2. 创建 TOC 样式文件

创建 `assets/css/extended/toc.css`：

**关键CSS变量：**
```css
:root {
  --nav-width: 1380px;
  --article-width: 650px;
  --toc-width: 300px;
}
```

**布局策略：**

#### 宽屏模式（≥1200px）
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

#### 小屏模式（<1200px）
```css
@media screen and (max-width: 1200px) {
  .toc-container.wide {
    position: relative;
    /* 切换为正常文档流 */
  }
}
```

### 3. 配置 Hugo 参数

在文章的 Front Matter 中启用TOC：

```yaml
---
title: "文章标题"
ShowToc: true      # 显示目录
TocOpen: true      # 默认展开目录（可选）
---
```

或在 `hugo.toml` 中全局启用：

```toml
[params]
  ShowToc = true
  TocOpen = true
```

## 技术细节

### JavaScript 工作原理

1. **页面加载时**：
   - 检测屏幕宽度，决定是否启用侧边模式
   - 获取所有带id的标题元素
   - 高亮第一个标题

2. **滚动时**：
   - 检测当前可视区域内的标题
   - 更新活动标题的高亮状态
   - 自动滚动TOC使活动链接居中显示

3. **窗口resize时**：
   - 重新检测屏幕宽度
   - 切换侧边/内联模式

### 触发阈值优化

**原始配置**：1440px（太高，需要缩放才能触发）
**优化后**：1200px（更容易在普通显示器上触发）

计算逻辑：
```javascript
function checkTocPosition() {
  const width = document.body.scrollWidth;
  if (width >= 1200) {
    // 启用侧边TOC
    tocContainer.classList.add("wide");
  } else {
    // 使用内联TOC
    tocContainer.classList.remove("wide");
  }
}
```

## 常见问题

### Q1: TOC需要缩放页面才显示？

**原因**：触发阈值设置过高（1440px）

**解决**：
- 修改 `toc.css` 中的 `@media screen and (max-width: 1200px)`
- 修改 `toc.html` 中的 `if (width >= 1200)` 判断

### Q2: TOC遮挡文章内容？

**原因**：使用了不当的布局方式（float或grid）

**解决**：使用 `position: absolute` 配合负值 `left`，将TOC定位在文章容器之外

### Q3: 长目录无法看到全部内容？

**解决**：已添加滚动条支持
```css
.toc .inner {
  max-height: calc(100vh - 2 * var(--gap) - 40px);
  overflow-y: auto;
}
```

## 额外优化

### 文章元信息位置调整

同时修改了 `layouts/_default/single.html`，将文章元信息（日期、作者、阅读次数）从页头移到页脚：

```html
<!-- 移动前：在 header 中 -->
<header class="post-header">
  <div class="post-meta">...</div>
</header>

<!-- 移动后：在 footer 中 -->
<footer class="post-footer">
  <div class="post-meta">...</div>
</footer>
```

### 样式优化

在 `custom.css` 中添加footer元信息样式：

```css
.post-footer .post-meta {
  padding: 15px 0;
  margin-bottom: 15px;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  color: var(--secondary);
  font-size: 14px;
}
```

## 部署说明

修改文件后推送到GitHub，会自动触发GitHub Actions部署流水线。

相关文件：
- `.github/workflows/deploy.yml` - 部署工作流配置
- 已添加超时和错误处理，避免流水线卡住

## 参考资源

- [周鑫的博客 - PaperMod侧边目录实现](https://www.zhouxin.space/logs/introduce-side-toc-and-reading-percentage-to-papermod/)
- [Hugo PaperMod 主题文档](https://github.com/adityatelange/hugo-PaperMod)
- [Hugo 官方文档 - Table of Contents](https://gohugo.io/content-management/toc/)

## 更新日志

### 2025-11-19
- ✅ 实现侧边TOC功能
- ✅ 添加自动高亮和滚动定位
- ✅ 降低触发阈值从1440px到1200px
- ✅ 修复文章元信息位置
- ✅ 优化GitHub Actions工作流
