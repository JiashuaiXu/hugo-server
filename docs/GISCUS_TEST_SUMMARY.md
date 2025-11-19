# Giscus 评论系统修复总结

## 问题诊断

评论系统无法显示的原因：

1. **评论模板为空**：`layouts/partials/comments.html` 文件只有注释，没有实际的 giscus 代码
2. **条件判断不匹配**：`single.html` 只检查文章级别的 `comments` 参数，不支持全局配置

## 解决方案

### 1. 创建评论模板
在 `jesse-blog/themes/hugo-PaperMod/layouts/partials/comments.html` 中添加 giscus 脚本：
- 从 `hugo.toml` 中读取所有配置参数
- 支持默认值
- 使用 Hugo 模板语法动态生成

### 2. 修改主题逻辑
修改 `jesse-blog/themes/hugo-PaperMod/layouts/_default/single.html`：
```diff
- {{- if (.Param "comments") }}
+ {{- if (or (.Param "comments") .Site.Params.comments.enabled) }}
```

现在支持：
- ✅ 全局启用评论（通过 `params.comments.enabled = true`）
- ✅ 单篇文章禁用评论（`comments: false`）
- ✅ 单篇文章强制启用（`comments: true`）

## 验证结果

```bash
# 构建成功，无错误
cd jesse-blog && hugo --quiet

# 所有文章页面都包含 giscus 脚本
grep -r "giscus.app/client.js" public/posts/
```

生成的 HTML 包含完整的 giscus 配置：
- ✅ data-repo: JiashuaiXu/hugo-server
- ✅ data-repo-id: R_kgDOKqBmgw
- ✅ data-category: Announcements
- ✅ data-category-id: DIC_kwDOKqBmg84Cx8uf
- ✅ data-theme: preferred_color_scheme（自动适配暗色/亮色模式）
- ✅ data-lang: zh-CN

## 下一步

运行 `./dev.sh` 或 `hugo server -D` 在浏览器中测试评论显示是否正常。

