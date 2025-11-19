# PaperMod 主题 Fork 迁移说明

## 迁移原因

GitHub Actions 部署失败,错误信息:
```
remote error: upload-pack: not our ref 604d063fc39c2a9bf6173205afbd92ab6acbaa95
```

**问题原因**: 
- 主题 submodule 原本指向上游仓库 `adityatelange/hugo-PaperMod`
- 本地有自定义修改(版本兼容性、giscus 支持)的 commits
- 这些 commits 无法推送到上游仓库(无权限)
- GitHub Actions 尝试 checkout 这些不存在的 commits 时失败

## 解决方案

将主题 submodule 切换到 fork 的仓库,允许推送自定义修改。

## 迁移步骤

### 1. Fork 上游仓库

在 GitHub 上 fork:
- 上游: `https://github.com/adityatelange/hugo-PaperMod`
- Fork: `https://github.com/JiashuaiXu/hugo-PaperMod`

### 2. 更新本地主题仓库的 remote

```bash
cd jesse-blog/themes/hugo-PaperMod
git remote set-url origin git@github.com:JiashuaiXu/hugo-PaperMod.git
```

### 3. 推送本地修改到 fork

```bash
git push origin master
```

### 4. 更新主仓库的 .gitmodules

```bash
cd /home/jesse/github/hugo-server
git config -f .gitmodules submodule.jesse-blog/themes/hugo-PaperMod.url git@github.com:JiashuaiXu/hugo-PaperMod.git
git submodule sync
```

### 5. 提交并推送更改

```bash
git add .gitmodules
git commit -m "chore: update PaperMod submodule to use forked repository"
git push
```

## 主题仓库的自定义修改

Fork 中包含以下自定义 commits:

### Commit 1: `539eb4f` - 版本兼容性修复
```
fix: lower Hugo version requirement for compatibility

- Change min_version from 0.146.0 to 0.100.0 in theme.toml
- Update version check in baseof.html to match current Hugo 0.143.1
- Temporary fix until Hugo version is upgraded via nix flake
```

**修改文件**:
- `theme.toml` - 降低最小版本要求
- `layouts/_default/baseof.html` - 更新版本检查逻辑

### Commit 2: `604d063` - Giscus 评论系统
```
feat: add giscus comment system support

- Implement giscus integration in comments.html partial
- Update single.html to include comments section
- Configure via hugo.toml params.comments.giscus settings
```

**修改文件**:
- `layouts/partials/comments.html` - 添加 giscus 集成
- `layouts/_default/single.html` - 包含评论区域

## 配置对比

### 修改前
```toml
[submodule "jesse-blog/themes/hugo-PaperMod"]
    path = jesse-blog/themes/hugo-PaperMod
    url = https://github.com/adityatelange/hugo-PaperMod.git
```

### 修改后
```toml
[submodule "jesse-blog/themes/hugo-PaperMod"]
    path = jesse-blog/themes/hugo-PaperMod
    url = git@github.com:JiashuaiXu/hugo-PaperMod.git
```

## 后续维护

### 同步上游更新

如需同步上游 PaperMod 的最新更新:

```bash
cd jesse-blog/themes/hugo-PaperMod

# 添加上游仓库(如果还没添加)
git remote add upstream https://github.com/adityatelange/hugo-PaperMod.git

# 获取上游更新
git fetch upstream

# 合并上游的 master 分支
git merge upstream/master

# 解决可能的冲突后推送
git push origin master
```

### 更新主仓库引用

在主仓库中更新 submodule 引用:

```bash
cd /home/jesse/github/hugo-server
git add jesse-blog/themes/hugo-PaperMod
git commit -m "chore: update theme submodule to latest version"
git push
```

## 验证

### 本地验证

```bash
cd /home/jesse/github/hugo-server
git submodule status
# 应显示正确的 commit hash

cd jesse-blog
hugo --gc --minify
# 应成功构建
```

### GitHub Actions 验证

推送后检查 GitHub Actions 工作流:
- 访问: https://github.com/JiashuaiXu/hugo-server/actions
- 确认 deploy 工作流成功运行
- 检查 submodule checkout 步骤无错误

## 注意事项

1. **SSH vs HTTPS**: 使用 SSH URL (`git@github.com:`) 需要配置 SSH 密钥
2. **CI/CD 配置**: GitHub Actions 需要有权限访问 fork 的仓库
3. **保持同步**: 定期同步上游更新以获取主题的新功能和修复

## 相关文件

- 主仓库 `.gitmodules`: 定义 submodule 配置
- 主题仓库 `theme.toml`: 主题元数据和版本要求
- 主题仓库 `.git/config`: Git 配置(包含 remote URL)

## 相关提交

- 主仓库: `b857035` - chore: update PaperMod submodule to use forked repository
- 主题仓库: `539eb4f` - fix: lower Hugo version requirement for compatibility
- 主题仓库: `604d063` - feat: add giscus comment system support

## 迁移完成日期

2025-11-19
