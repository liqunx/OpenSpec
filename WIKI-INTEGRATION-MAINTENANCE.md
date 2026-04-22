# OpenSpec Wiki Integration - 个人维护指南

## 概述

本指南说明如何在 OpenSpec 上游不接受 PR 的情况下，持续使用 LLM Wiki 集成功能，同时保持与上游的同步。

## 分支策略

### 推荐分支结构

```
main                              # 跟踪上游 Fission-AI/OpenSpec/main
└── wiki-integration/main        # main + wiki 功能（你的日常工作分支）
    └── feature/xxx              # 基于 wiki-integration/main 开发新功能
```

### 当前状态

- ✅ `main` - 已同步到上游最新
- ✅ `feature/llm-wiki-integration` - 已提交 PR，等待审查
- ⚠️ 需要创建 `wiki-integration/main` - 用于日常使用

---

## 快速开始

### 1. 创建工作分支

```bash
# 确保在最新的 main 分支
git checkout main
git pull upstream main

# 基于 main 创建带 wiki 功能的分支
git checkout -b wiki-integration/main

# 合并你的 wiki 功能
git merge feature/llm-wiki-integration

# 推送到你的 fork
git push -u origin wiki-integration/main
```

### 2. 在项目中使用

在你的实际项目中，使用你 fork 的版本：

```bash
# 方法 1: 从你的 fork 安装
npm install -g git+https://github.com/liqunx/OpenSpec.git#wiki-integration/main

# 方法 2: 克隆后本地链接
cd ~/projects
git clone https://github.com/liqunx/OpenSpec.git
cd OpenSpec
git checkout wiki-integration/main
npm install
npm run build
npm link

# 然后在项目目录
cd your-project
openspec init
```

---

## 同步上游更新

### 定期同步流程（建议每周或每两周）

```bash
# 1. 切换到 main 分支
git checkout main

# 2. 拉取上游最新代码
git fetch upstream
git merge upstream/main

# 3. 推送到你的 fork
git push origin main

# 4. 切换到 wiki 分支
git checkout wiki-integration/main

# 5. 合并 main 的最新更改
git merge main

# 6. 解决可能的冲突（如果有）
# Git 会提示哪些文件有冲突
# 手动解决后：
git add .
git commit -m "Resolve merge conflicts with upstream"

# 7. 推送到你的 fork
git push origin wiki-integration/main

# 8. 重新构建和测试
npm install
npm run build
npm test
```

### 自动化同步脚本

创建 `scripts/sync-upstream.sh`（Linux/Mac）或 `scripts/sync-upstream.ps1`（Windows）：

#### Linux/Mac: `scripts/sync-upstream.sh`

```bash
#!/bin/bash
set -e

echo "🔄 Syncing with upstream OpenSpec..."

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)

# Switch to main and sync
git checkout main
git fetch upstream
git merge upstream/main --no-edit
git push origin main

# Switch to wiki branch and merge
git checkout wiki-integration/main
git merge main --no-edit

# Check for conflicts
if ! git diff --quiet HEAD; then
    echo "⚠️  Merge conflicts detected. Please resolve manually."
    echo "After resolving, run:"
    echo "  git add ."
    echo "  git commit -m 'Resolve merge conflicts'"
    echo "  git push origin wiki-integration/main"
    exit 1
fi

# Push changes
git push origin wiki-integration/main

# Rebuild
echo "🔨 Rebuilding..."
npm install
npm run build
npm test

# Switch back to original branch
git checkout $CURRENT_BRANCH

echo "✅ Sync complete!"
```

#### Windows: `scripts/sync-upstream.ps1`

```powershell
$ErrorActionPreference = "Stop"

Write-Host "🔄 Syncing with upstream OpenSpec..." -ForegroundColor Cyan

# Save current branch
$CURRENT_BRANCH = git branch --show-current

try {
    # Switch to main and sync
    git checkout main
    git fetch upstream
    git merge upstream/main --no-edit
    git push origin main

    # Switch to wiki branch and merge
    git checkout wiki-integration/main
    git merge main --no-edit

    # Check for conflicts
    $hasConflicts = git diff --quiet HEAD 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Merge conflicts detected. Please resolve manually." -ForegroundColor Yellow
        Write-Host "After resolving, run:" -ForegroundColor Yellow
        Write-Host "  git add ." -ForegroundColor Gray
        Write-Host "  git commit -m 'Resolve merge conflicts'" -ForegroundColor Gray
        Write-Host "  git push origin wiki-integration/main" -ForegroundColor Gray
        exit 1
    }

    # Push changes
    git push origin wiki-integration/main

    # Rebuild
    Write-Host "🔨 Rebuilding..." -ForegroundColor Cyan
    npm install
    npm run build
    npm test

    Write-Host "✅ Sync complete!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Sync failed: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Switch back to original branch
    git checkout $CURRENT_BRANCH
}
```

使用方法：

```bash
# Linux/Mac
chmod +x scripts/sync-upstream.sh
./scripts/sync-upstream.sh

# Windows
.\scripts\sync-upstream.ps1
```

---

## 处理冲突

### 常见冲突场景

#### 1. README.md 冲突

**原因：** 上游更新了 README，你也有修改

**解决：**
```bash
# 查看冲突
git diff README.md

# 手动编辑，保留双方的更改
# 然后标记为已解决
git add README.md
git commit -m "Merge upstream README updates with wiki integration section"
```

#### 2. 核心代码冲突

**原因：** 上游修改了你没有改动的文件，但合并时产生冲突

**解决：**
```bash
# 通常可以安全地接受上游版本
git checkout --theirs src/core/init.ts
git add src/core/init.ts
git commit -m "Accept upstream changes to init.ts"
```

#### 3. 技能模板冲突

**原因：** 上游更新了技能生成逻辑

**解决：**
- 检查上游是否有新的技能模板
- 确保你的 wiki 技能仍然兼容
- 必要时更新技能文件

---

## 版本管理

### 版本号策略

由于你是基于上游的 fork，建议使用：

```
上游版本 + 你的修订号

例如：
- 上游: v1.5.0
- 你的版本: v1.5.0-wiki.1, v1.5.0-wiki.2, ...
```

在 `package.json` 中：

```json
{
  "name": "@liqunx/openspec",
  "version": "1.5.0-wiki.1",
  "description": "OpenSpec with LLM Wiki integration"
}
```

### 发布到你的 npm（可选）

如果你想通过 npm 分享：

```bash
# 登录 npm
npm login

# 发布
npm publish --access public

# 使用时
npm install -g @liqunx/openspec
```

---

## 项目管理

### 在你的 Fork 中管理 Issues

1. **启用 Issues**
   - 在你的 GitHub fork 仓库设置中启用 Issues
   - 记录你自己的 bug 和功能请求

2. **标签系统**
   ```
   - bug: 你的 wiki 功能的 bug
   - enhancement: 改进建议
   - upstream-sync: 需要同步上游的问题
   - documentation: 文档相关
   ```

3. **里程碑**
   - `v1.5.0-wiki.1`: 初始版本
   - `v1.5.0-wiki.2`: 修复和改进
   - `v1.6.0-wiki.1`: 跟随上游 v1.6.0

### 贡献者指南

如果你有其他使用者，创建 `CONTRIBUTING.md`：

```markdown
# Contributing to OpenSpec Wiki Integration

## Reporting Issues

Please report issues at: https://github.com/liqunx/OpenSpec/issues

## Development Setup

1. Fork the repository
2. Clone your fork
3. Checkout `wiki-integration/main` branch
4. Install dependencies: `npm install`
5. Build: `npm run build`

## Syncing with Upstream

Run the sync script regularly:
```bash
./scripts/sync-upstream.sh
```

## Submitting Changes

1. Create a feature branch from `wiki-integration/main`
2. Make your changes
3. Test thoroughly
4. Submit a PR to `wiki-integration/main`
```

---

## 监控上游变化

### 1. GitHub Watch

- Watch `Fission-AI/OpenSpec` 仓库
- 选择 "Releases only" 或 "All Activity"

### 2. RSS Feed

订阅上游的 releases RSS：
```
https://github.com/Fission-AI/OpenSpec/releases.atom
```

### 3. 自动化通知

使用 GitHub Actions 定期检查上游更新：

创建 `.github/workflows/check-upstream.yml`：

```yaml
name: Check Upstream Updates

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM UTC
  workflow_dispatch:

jobs:
  check-updates:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Fetch upstream
        run: |
          git remote add upstream https://github.com/Fission-AI/OpenSpec.git
          git fetch upstream

      - name: Check for new commits
        id: check
        run: |
          UPSTREAM_MAIN=$(git rev-parse upstream/main)
          LOCAL_MAIN=$(git rev-parse origin/main)
          
          if [ "$UPSTREAM_MAIN" != "$LOCAL_MAIN" ]; then
            echo "has_updates=true" >> $GITHUB_OUTPUT
            echo "Upstream has new commits!"
          else
            echo "has_updates=false" >> $GITHUB_OUTPUT
            echo "Up to date with upstream"
          fi

      - name: Create Issue if updates available
        if: steps.check.outputs.has_updates == 'true'
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '🔄 Upstream OpenSpec has updates',
              body: 'New commits are available in upstream/main. Run the sync script to update.',
              labels: ['upstream-sync']
            })
```

---

## 最佳实践

### 1. 定期同步

- **频率：** 每周或每两周
- **时机：** 在你开始新功能之前
- **好处：** 减少冲突，保持最新

### 2. 小批量提交

- 每次同步后立即提交
- 清晰的提交信息
- 便于回滚和追踪

### 3. 测试驱动

- 每次同步后运行测试
- 确保 wiki 功能仍然工作
- 在真实项目中验证

### 4. 文档更新

- 记录重要的变更
- 更新使用说明
- 保持 CHANGELOG 最新

### 5. 备份策略

```bash
# 定期备份你的 fork
git clone --mirror https://github.com/liqunx/OpenSpec.git backup-repo
cd backup-repo
git remote set-url --push origin /path/to/local/backup
git push --mirror
```

---

## 故障排除

### 问题 1：同步时大量冲突

**原因：** 太久没有同步

**解决：**
```bash
# 重置到上游 main
git checkout main
git reset --hard upstream/main
git push origin main --force

# 重新应用你的更改
git checkout wiki-integration/main
git rebase main

# 逐个解决冲突
```

### 问题 2：npm 包依赖冲突

**原因：** 上游更新了依赖版本

**解决：**
```bash
# 删除 node_modules 和 lock 文件
rm -rf node_modules package-lock.json

# 重新安装
npm install

# 测试
npm run build
npm test
```

### 问题 3：技能不工作

**原因：** 上游改变了技能加载机制

**解决：**
1. 检查上游的技能目录结构
2. 确认你的技能文件格式正确
3. 查看上游的 changelog
4. 必要时调整技能文件

---

## 长期维护计划

### 短期（1-3 个月）

- [ ] 建立定期同步习惯
- [ ] 收集用户反馈
- [ ] 修复发现的 bug
- [ ] 完善文档

### 中期（3-6 个月）

- [ ] 考虑发布独立的 npm 包
- [ ] 添加更多 IDE 的 hooks 示例
- [ ] 优化同步脚本
- [ ] 建立社区（如果有其他用户）

### 长期（6+ 个月）

- [ ] 评估是否继续维护 fork
- [ ] 如果上游接受了 PR，迁移回去
- [ ] 或者发展为独立项目
- [ ] 寻找维护者分担工作

---

## 如果上游接受了 PR

如果未来上游接受了你的 PR：

```bash
# 1. 切换到 main
git checkout main

# 2. 拉取包含你 PR 的上游代码
git fetch upstream
git merge upstream/main

# 3. 删除 wiki 分支（不再需要）
git branch -d wiki-integration/main
git push origin --delete wiki-integration/main

# 4. 以后直接使用上游版本
npm install -g @fission-ai/openspec@latest
```

---

## 资源链接

- **你的 Fork:** https://github.com/liqunx/OpenSpec
- **上游仓库:** https://github.com/Fission-AI/OpenSpec
- **PR 链接:** https://github.com/Fission-AI/OpenSpec/pull/[PR_NUMBER]
- **集成文档:** docs/guides/llm-wiki-integration.md
- **示例配置:** examples/wiki-integration/

---

**最后更新:** 2026-04-22  
**维护者:** liqunx  
**许可证:** MIT (与 OpenSpec 相同)
