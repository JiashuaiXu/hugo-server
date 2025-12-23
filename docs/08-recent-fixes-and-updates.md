# 08: 最近一次“文章无法更新 / 构建失败 / 内容目录控制”的修复总结（2025-12）

本文汇总本次排查与修复的关键问题、原因、处理动作和后续最佳实践，方便后续回溯与复用。

---

## 1. 问题 1：文章无法更新（内容仓库改了，但站点不变）

### 现象

- `hugo-server/jesse-blog/content/` 为空或内容落后
- GitHub Actions 构建时看不到最新文章
- 本地以为“写了文章”，但线上始终不更新

### 根因

- **`jesse-blog/content` 子模块未初始化**（`git submodule status` 显示前缀 `-`）
- 或者内容仓库（`obsidian-notes`）的改动 **未提交/未推送**，CI 自然拉不到
- 或者 `hugo-server` 主仓库 **未更新子模块引用**，导致构建仍指向旧的 submodule commit

### 修复动作

在 `hugo-server` 仓库：

- 初始化并更新子模块：
  - `git submodule update --init --recursive`

在 `obsidian-notes` 仓库：

- 把本地更改（新增/修改文章）提交并推送：
  - `git add -A`
  - `git commit -m "..."`
  - `git push`

回到 `hugo-server` 仓库：

- 拉取子模块最新 commit，并提交“子模块引用更新”：
  - `cd jesse-blog/content && git pull`
  - `cd ../.. && git add jesse-blog/content`
  - `git commit -m "chore: 更新 content 子模块引用 ..."`
  - `git push`

> 说明：如果你的工作流是“内容仓库 push -> 触发 hugo-server 构建”，依然需要保证 `hugo-server` 在构建时指向的 submodule commit 是最新；否则构建拿到的还是旧内容。

---

## 2. 问题 2：GitHub Actions 构建失败（REF_NOT_FOUND）

### 现象

CI 构建日志报错类似：

- `REF_NOT_FOUND: Ref "xxx.md": ".../content/posts/写作规范与命名规范.md:line:col": page not found`

### 根因

- 文章里出现了 Hugo Shortcode：`{{< relref "xxx.md" >}}`
- 但 `relref` 指向的页面不存在（或路径不匹配）
- 且这些短代码 **即使写在 Markdown 代码块里**，也可能被解析并执行，从而在构建阶段直接失败

### 修复动作

把“示例短代码”改为 **转义短代码**，只展示不执行：

- `{{< relref "xxx.md" >}}` ➜ `{{</* relref "xxx.md" */>}}`

并避免在示例脚本字符串中拼接可执行短代码（改成普通文本示例）。

---

## 3. 内容控制：不希望编译 `copilot/` 目录

### 现象

`content/copilot/` 下的笔记/提示词也被 Hugo 当成内容页面构建、出现在列表或索引里。

### 根因

Hugo 默认会把 `content/` 目录下的 Markdown 当作内容页。并且配置里曾把 `copilot` 作为主页聚合 section（`mainSections`）。

### 修复动作

在 `jesse-blog/hugo.toml`：

- 从 `mainSections` 移除 `copilot`
- 新增 `ignoreFiles` 正则规则，忽略 `content/copilot/**`：

```toml
ignoreFiles = [
  "content/copilot/.*",
  "copilot/.*",
]
```

> 说明：`ignoreFiles` 是正则匹配相对路径，用于彻底把指定内容排除在构建之外。

---

## 4. 内容新增：About 页面加入 GitHub 跳转链接

### 目标

在 `/about/` 页面加入 GitHub 主页跳转链接（`https://github.com/JiashuaiXu/`），并补充简短的个人信息/联系方式。

### 变更位置

- 内容仓库：`obsidian-notes/about/index.md`
- 经由子模块同步到：`hugo-server/jesse-blog/content/about/index.md`

---

## 5. 新增文章：在 `posts/go/` 下增加 Hugo 技术栈解析

### 变更位置

- `obsidian-notes/posts/go/hugo-tech-stack-and-architecture.md`

### 结论（关于多级目录）

在 `content/posts/` 下建立多级目录（例如 `posts/go/xxx.md`），**Hugo 仍然会编译与索引**，只要它们属于 Regular Pages 且没有被 `draft` / `ignoreFiles` 等规则排除。

---

## 6. 推荐的日常发布流程（最不容易踩坑）

1. 在 `obsidian-notes` 写作并提交推送
2. 确认 GitHub Actions 已触发（`obsidian-notes` -> `hugo-server`）
3. 若你的构建依赖 submodule 引用：
   - 确认 `hugo-server` 主仓库已更新 submodule 指向最新 commit（或让 workflow 自动更新引用）

---

## 7. 快速自检清单（5 个点）

- `hugo-server`：`git submodule status` 没有 `-` 前缀
- `obsidian-notes`：`git status` 没有未提交变更
- `obsidian-notes`：改动已经 `git push`
- `hugo-server`：子模块引用更新也已 push（如果你的流程需要）
- 内容里没有未转义的示例短代码（尤其是 `relref/ref`）


