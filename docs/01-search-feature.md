# 功能1: 站内搜索功能

## 功能说明

在博客中添加全站搜索功能,支持搜索文章标题、内容、标签等。

## 实现效果

- 导航栏显示 "Search" 菜单项
- 点击进入专门的搜索页面
- 实时搜索,无需后端支持
- 使用 Fuse.js 提供模糊搜索功能

## 配置步骤

### 1. 修改 hugo.toml

在 `jesse-blog/hugo.toml` 中添加以下配置:

```toml
# 添加搜索菜单项
[[menu.main]]
  identifier = "search"
  name = "Search"
  url = "/search/"
  weight = 25

# 启用 JSON 输出(搜索索引)
[outputs]
  home = ["HTML", "RSS", "JSON"]  # 注意添加 "JSON"
  section = ["HTML", "RSS"]
  taxonomy = ["HTML", "RSS"]
  term = ["HTML", "RSS"]
```

### 2. 创建搜索页面

创建文件 `jesse-blog/content/search/index.md`:

```markdown
---
title: "Search"
layout: "search"
summary: "search"
placeholder: "搜索文章..."
---
```

## 工作原理

1. Hugo 构建时会生成 `index.json` 文件,包含所有文章的索引
2. PaperMod 主题内置了搜索页面布局和 Fuse.js 库
3. 用户输入搜索词时,JavaScript 在本地搜索索引文件
4. 实时显示匹配结果

## 移除步骤

如需移除此功能:

1. 从 `hugo.toml` 中删除搜索菜单项:
```toml
# 删除此部分
[[menu.main]]
  identifier = "search"
  name = "Search"
  url = "/search/"
  weight = 25
```

2. 将 `[outputs]` 中的 `"JSON"` 移除:
```toml
[outputs]
  home = ["HTML", "RSS"]  # 移除 "JSON"
```

3. 删除搜索页面:
```bash
rm -rf jesse-blog/content/search/
```

4. 重新构建:
```bash
cd jesse-blog && hugo --gc --minify
```

## 测试

```bash
cd jesse-blog
hugo server -D
```

访问 http://localhost:1313/search/ 测试搜索功能

## 注意事项

- 每次添加新文章后需要重新构建站点以更新搜索索引
- 只搜索已发布的文章 (draft: false)
- 搜索是在客户端进行的,不会增加服务器负担
