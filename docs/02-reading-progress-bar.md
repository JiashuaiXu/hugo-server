# 功能2: 顶部阅读进度条

## 功能说明

在页面顶部显示一个进度条,根据页面滚动位置实时显示阅读进度。

## 实现效果

- 页面最顶部显示 3px 高的紫色渐变进度条
- 随着页面向下滚动,进度条宽度增加
- 滚动到页面底部时,进度条达到 100%
- 平滑过渡动画效果

## 配置步骤

### 1. 创建 extend_head.html

创建文件 `jesse-blog/layouts/partials/extend_head.html`:

```html
<!-- 阅读进度条样式 -->
<style>
  .reading-progress-bar {
    position: fixed;
    top: 0;
    left: 0;
    height: 3px;
    background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    width: 0%;
    z-index: 9999;
    transition: width 0.2s ease;
  }
</style>
```

### 2. 在 extend_footer.html 中添加进度条 HTML 和 JS

在 `jesse-blog/layouts/partials/extend_footer.html` 中添加:

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

## 自定义样式

你可以修改进度条的颜色、高度等:

```css
.reading-progress-bar {
  height: 4px;  /* 修改高度 */
  background: linear-gradient(90deg, #ff6b6b 0%, #4ecdc4 100%);  /* 修改颜色 */
  /* 或使用纯色: background: #667eea; */
}
```

## 移除步骤

1. 从 `jesse-blog/layouts/partials/extend_head.html` 中删除进度条样式部分

2. 从 `jesse-blog/layouts/partials/extend_footer.html` 中删除:
   - `<div class="reading-progress-bar" id="reading-progress"></div>`
   - 进度条相关的 `<script>` 标签

3. 如果这两个文件没有其他内容,可以直接删除:
```bash
# 如果文件为空或只有进度条代码,可以删除
rm jesse-blog/layouts/partials/extend_head.html
rm jesse-blog/layouts/partials/extend_footer.html
```

## 工作原理

1. CSS 创建一个固定在顶部的进度条元素
2. JavaScript 监听页面滚动事件
3. 计算当前滚动位置占总可滚动高度的百分比
4. 动态更新进度条宽度

## 注意事项

- 进度条使用 `z-index: 9999` 确保在所有元素之上
- 适用于所有页面(首页、文章页、列表页等)
- 对页面性能影响极小
- 在移动端和桌面端都能正常工作
