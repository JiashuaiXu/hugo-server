# 09: 一键发布脚本（本地自动提交 + 推送 + 更新子模块引用）

本项目的 CI/CD 已经支持 “obsidian-notes push → 触发 hugo-server 构建并自动更新子模块引用”。  
但在本地写作时，你可能仍希望 **一条命令**完成以下操作：

- `obsidian-notes`：`git add/commit/push`
- `hugo-server`：更新 `jesse-blog/content` 子模块到最新，并提交/推送“子模块引用更新”

为此提供脚本：`hugo-server/scripts/publish.ps1`（PowerShell 7）。

---

## 1. 目录结构要求

脚本默认你本地目录长这样：

```
blog/
├── hugo-server/
└── obsidian-notes/
```

如果你的路径不同，可以用参数覆盖（见下文）。

---

## 2. 最常用命令

在 `hugo-server` 目录运行：

```powershell
pwsh -File .\scripts\publish.ps1 -Message "Add: 新文章标题"
```

它会：

1. 在 `obsidian-notes` 检测变更，有变更则 commit 并 push
2. 在 `hugo-server/jesse-blog/content` 拉取 `origin/main` 最新
3. 在 `hugo-server` 提交并 push 子模块引用更新（触发部署）

---

## 3. 常用参数

- `-SkipObsidianPush`：只更新 `hugo-server` 的子模块引用，不提交/推送 `obsidian-notes`

```powershell
pwsh -File .\scripts\publish.ps1 -SkipObsidianPush
```

- `-SkipHugoServerPush`：只在本地提交，不 push（想先本地验证时）

```powershell
pwsh -File .\scripts\publish.ps1 -Message "Update: 修复排版" -SkipHugoServerPush
```

- `-ObsidianNotesPath` / `-HugoServerPath`：自定义仓库路径

```powershell
pwsh -File .\scripts\publish.ps1 `
  -ObsidianNotesPath "D:\repos\obsidian-notes" `
  -HugoServerPath "D:\repos\hugo-server" `
  -Message "Add: 新文章"
```

---

## 4. 说明与注意事项

- 脚本会自动处理 Windows 上常见的 Git 报错：`detected dubious ownership`（通过 `safe.directory`）
- 如果你的 Git 没有配置凭据（HTTPS/SSH），push 可能失败；先确保你能在两个仓库手动 `git push` 成功一次
- 完成后站点更新需要等待 GitHub Actions 构建部署（通常 2–5 分钟）


