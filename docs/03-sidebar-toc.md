# 功能3: 目录侧边栏

## 功能说明

将文章目录(TOC - Table of Contents)显示在侧边栏,而不是文章顶部,方便导航。

## 实现效果

- **桌面端(屏幕宽度 > 1200px)**: 目录固定在右侧边栏,跟随滚动
- **移动端(屏幕宽度 < 1200px)**: 目录显示在文章顶部
- 支持点击跳转到对应章节
- 自动高亮当前阅读的章节(主题自带)

## 配置步骤

### 1. 修改 hugo.toml

在 `jesse-blog/hugo.toml` 的 `[params]` 部分添加:

```toml
[params]
  # ... 其他配置 ...
  
  # 启用目录侧边栏
  ShowToc = true
  TocOpen = true
  TocSide = 'right'  # 目录显示在右侧
```

同时配置目录的层级范围:

```toml
[markup.tableOfContents]
  endLevel = 3      # 显示到 h3
  ordered = false   # 使用无序列表
  startLevel = 2    # 从 h2 开始
```

### 2. 创建自定义 CSS

创建文件 `jesse-blog/assets/css/extended/custom.css`:

```css
/* 侧边栏目录样式 */
.toc {
  position: sticky;
  top: 80px;
  max-height: calc(100vh - 100px);
  overflow-y: auto;
  padding: 20px;
  background: var(--entry);
  border-radius: 8px;
  border: 1px solid var(--border);
  margin-left: 20px;
}

.post-content {
  display: grid;
  grid-template-columns: 1fr;
  gap: 20px;
}

@media (min-width: 1200px) {
  .post-content {
    grid-template-columns: minmax(0, 3fr) minmax(250px, 1fr);
  }
  
  .toc {
    order: 2;
  }
  
  .post-single .post-content > *:not(.toc) {
    order: 1;
  }
}

@media (max-width: 1199px) {
  .toc {
    position: relative;
    top: 0;
    margin-left: 0;
    margin-bottom: 20px;
  }
}

/* 优化TOC样式 */
.toc details {
  border: none;
}

.toc details summary {
  cursor: pointer;
  font-weight: 600;
  margin-bottom: 10px;
}

.toc ul {
  padding-left: 0;
}

.toc li {
  list-style: none;
  margin: 8px 0;
  padding-left: 15px;
  border-left: 2px solid var(--border);
}

.toc li:hover {
  border-left-color: var(--primary);
}

.toc a {
  color: var(--content);
  text-decoration: none;
  font-size: 14px;
  line-height: 1.6;
}

.toc a:hover {
  color: var(--primary);
}

/* 滚动条样式 */
.toc::-webkit-scrollbar {
  width: 6px;
}

.toc::-webkit-scrollbar-track {
  background: var(--code-bg);
  border-radius: 3px;
}

.toc::-webkit-scrollbar-thumb {
  background: var(--border);
  border-radius: 3px;
}

.toc::-webkit-scrollbar-thumb:hover {
  background: var(--primary);
}
```

## 自定义配置

### 调整目录宽度

修改 CSS 中的 `grid-template-columns`:

```css
@media (min-width: 1200px) {
  .post-content {
    /* 第一个值是文章宽度,第二个是TOC宽度 */
    grid-template-columns: minmax(0, 3fr) minmax(300px, 1fr);
  }
}
```

### 调整目录显示的标题层级

在 `hugo.toml` 中修改:

```toml
[markup.tableOfContents]
  startLevel = 1  # 从 h1 开始
  endLevel = 4    # 显示到 h4
```

### 将 TOC 移到左侧

修改 `hugo.toml`:

```toml
[params]
  TocSide = 'left'  # 改为左侧
```

然后调整 CSS 的 `margin-left` 为 `margin-right`。

## 移除步骤

1. 从 `hugo.toml` 中删除或注释 TOC 相关配置:
```toml
[params]
  # ShowToc = true
  # TocOpen = true
  # TocSide = 'right'
```

2. 删除或注释 `[markup.tableOfContents]` 部分

3. 从 `jesse-blog/assets/css/extended/custom.css` 中删除 TOC 相关样式

4. 如果 custom.css 文件为空,可以删除:
```bash
rm jesse-blog/assets/css/extended/custom.css
```

## 注意事项

- 只有文章包含标题(h2, h3等)时才会显示目录
- 可以在文章的 front matter 中单独控制是否显示 TOC:
  ```yaml
  ---
  title: "文章标题"
  ShowToc: false  # 不显示目录
  ---
  ```
- 目录会自动折叠/展开(由 `TocOpen` 控制)
- 使用 CSS 变量(如 `var(--entry)`)确保与主题配色保持一致

## 工作原理

1. Hugo 根据文章标题自动生成 TOC HTML
2. CSS Grid 布局将内容分为两列(文章 + TOC)
3. 媒体查询在移动端切换为单列布局
4. `position: sticky` 使 TOC 在滚动时保持可见
