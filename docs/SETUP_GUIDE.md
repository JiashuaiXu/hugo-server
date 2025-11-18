# GitHub Actions 自动化部署配置指南

## 概述

新的自动化工作流程：
- **obsidian-notes** 内容更新 → 触发 **hugo-server** 构建 → 部署到 **JiashuaiXu.github.io**

## 配置步骤

### 1️⃣ 创建 GitHub Personal Access Token

1. 访问 GitHub：https://github.com/settings/tokens
2. 点击 **Generate new token** → **Generate new token (classic)**
3. 设置：
   - **Note**: `Hugo Deployment Token`
   - **Expiration**: `No expiration` 或选择合适的过期时间
   - **Select scopes**: 勾选以下权限：
     - ✅ `repo` (完整的仓库访问权限)
     - ✅ `workflow` (允许更新 GitHub Actions workflows)

4. 点击 **Generate token**
5. **⚠️ 重要**: 复制生成的 token（只显示一次！）

### 2️⃣ 在 hugo-server 仓库添加 Secret

1. 访问：https://github.com/JiashuaiXu/hugo-server/settings/secrets/actions
2. 点击 **New repository secret**
3. 添加：
   - **Name**: `GH_PAT`
   - **Secret**: 粘贴刚才复制的 token
4. 点击 **Add secret**

### 3️⃣ 在 obsidian-notes 仓库添加 Secret

1. 访问：https://github.com/JiashuaiXu/obsidian-notes/settings/secrets/actions
2. 点击 **New repository secret**
3. 添加：
   - **Name**: `GH_PAT`
   - **Secret**: 粘贴相同的 token
4. 点击 **Add secret**

### 4️⃣ 部署 obsidian-notes workflow

在 obsidian-notes 仓库中创建文件：

```bash
# 在 obsidian-notes 仓库根目录
mkdir -p .github/workflows
```

复制 `obsidian-notes-workflow.yml` 的内容到：
```
.github/workflows/trigger-hugo.yml
```

提交并推送：
```bash
git add .github/workflows/trigger-hugo.yml
git commit -m "Add GitHub Actions trigger for Hugo build"
git push
```

### 5️⃣ 提交 hugo-server 的 workflow

在 hugo-server 仓库（当前仓库）：

```bash
git add .github/workflows/deploy.yml
git add dev.sh deploy.sh deploy.sh.backup
git add SETUP_GUIDE.md
git commit -m "Add automated deployment with GitHub Actions"
git push
```

## 使用流程

### 📝 日常写作

1. 在 Obsidian 中编辑内容
2. 提交并推送到 obsidian-notes：
   ```bash
   cd jesse-blog/content  # 或者在 obsidian-notes 仓库
   git add .
   git commit -m "Add new post"
   git push
   ```
3. ✨ 自动触发构建和部署！

### 🎨 本地预览（修改主题、调试样式）

```bash
# 默认本地预览
./dev.sh

# 局域网访问（其他设备预览）
./dev.sh 0.0.0.0

# 自定义 baseURL（内网访问）
./dev.sh 0.0.0.0 http://192.168.1.100:1313
```

### 🔧 修改主题/配置

1. 本地修改 `jesse-blog/hugo.toml` 或主题文件
2. 使用 `./dev.sh` 预览效果
3. 满意后提交：
   ```bash
   git add jesse-blog/
   git commit -m "Update theme configuration"
   git push
   ```
4. ✨ 自动触发构建和部署！

### 🚀 手动触发部署

访问 GitHub Actions 页面手动触发：
https://github.com/JiashuaiXu/hugo-server/actions/workflows/deploy.yml

点击 **Run workflow**

## 故障排查

### Actions 失败

1. 检查 GitHub Actions 日志：
   - hugo-server: https://github.com/JiashuaiXu/hugo-server/actions
   - obsidian-notes: https://github.com/JiashuaiXu/obsidian-notes/actions

2. 常见问题：
   - ❌ `GH_PAT` 或 `GH_PAT` 未设置
   - ❌ Token 权限不足（需要 `repo` 和 `workflow`）
   - ❌ Token 已过期

### 内容更新但未触发构建

1. 检查 obsidian-notes 的 workflow 是否存在
2. 确认推送的文件路径匹配 workflow 的 `paths` 配置
3. 检查 `GH_PAT` 是否正确设置

### 仍然出现 Git 冲突

- ⚠️ 确保不再使用 `./deploy.sh.backup` 手动部署
- 完全依赖 GitHub Actions 自动部署

## 回滚到手动部署

如果需要临时回到手动部署：

```bash
# 禁用 GitHub Actions（删除或重命名 workflow 文件）
mv .github/workflows/deploy.yml .github/workflows/deploy.yml.disabled

# 使用旧的部署脚本
./deploy.sh.backup
```

## 架构图

```
┌─────────────────────┐
│  Obsidian 编辑内容   │
│  (obsidian-notes)   │
└──────────┬──────────┘
           │ git push
           ▼
┌─────────────────────┐
│  GitHub Actions     │  触发
│  (obsidian-notes)   │───────┐
└─────────────────────┘       │
                              │
                              ▼
                    ┌─────────────────────┐
                    │  GitHub Actions     │
                    │  (hugo-server)      │
                    │  - Pull content     │
                    │  - Build Hugo       │
                    │  - Deploy           │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  GitHub Pages       │
                    │  JiashuaiXu.github.io│
                    └─────────────────────┘
```

## 下一步

配置完成后，测试工作流程：

1. 在 obsidian-notes 中创建测试文章
2. 推送到 GitHub
3. 观察 Actions 是否成功执行
4. 访问 https://JiashuaiXu.github.io 确认部署成功

祝你使用愉快！🎉
