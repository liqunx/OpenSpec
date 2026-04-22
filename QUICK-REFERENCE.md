# OpenSpec Wiki Integration - 快速参考

## 🚀 立即开始使用

### 在你的项目中安装

```bash
# 方法 1: 直接从 GitHub 安装（推荐）
npm install -g git+https://github.com/liqunx/OpenSpec.git#wiki-integration/main

# 方法 2: 本地开发模式
cd ~/projects/OpenSpec
git checkout wiki-integration/main
npm install
npm run build
npm link

# 然后在你的项目目录
cd your-project
openspec init
```

### 配置 Wiki

```bash
# 1. 创建 wiki 目录结构
mkdir -p openspec/docs/wiki/features
mkdir -p openspec/docs/raw/00-uncategorized
mkdir -p openspec/docs/schema

# 2. 复制技能文件到你的 AI 工具
cp -r examples/wiki-integration/skills/openspec-wiki-query .claude/skills/
cp -r examples/wiki-integration/skills/openspec-wiki-ingest .claude/skills/

# 3. 配置 hooks（参考 claude-settings.json）

# 4. 重启 IDE
```

---

## 🔄 同步上游（每周一次）

```bash
# 自动同步（推荐）
cd ~/projects/OpenSpec
.\scripts\sync-upstream.ps1

# 或者手动同步
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

git checkout wiki-integration/main
git merge main
git push origin wiki-integration/main

npm install && npm run build && npm test
```

---

## 📁 重要文件位置

```
OpenSpec/
├── docs/guides/llm-wiki-integration.md    # 完整文档
├── examples/wiki-integration/              # 示例配置
│   ├── skills/                             # 技能文件
│   ├── claude-settings.json                # Hooks 示例
│   └── README.md                           # 使用说明
├── scripts/sync-upstream.ps1               # 同步脚本
└── WIKI-INTEGRATION-MAINTENANCE.md         # 维护指南
```

---

## 🎯 常用命令

```bash
# 查看当前分支
git branch

# 切换到 wiki 分支
git checkout wiki-integration/main

# 检查是否有上游更新
git fetch upstream
git log HEAD..upstream/main

# 查看状态
git status

# 重新构建
npm run build

# 运行测试
npm test
```

---

## ⚠️ 常见问题

### Q: 如何知道上游有更新？

A: 
```bash
git fetch upstream
git log HEAD..upstream/main --oneline
```
如果有输出，说明有更新。

### Q: 同步时出现冲突怎么办？

A:
1. 查看冲突文件：`git diff --name-only --diff-filter=U`
2. 手动编辑解决冲突
3. 标记已解决：`git add .`
4. 完成合并：`git commit`
5. 推送：`git push origin wiki-integration/main`

### Q: 技能不工作？

A:
1. 确认技能在正确目录（如 `.claude/skills/`）
2. 检查 YAML frontmatter 格式
3. 重启 IDE
4. 查看 IDE 日志

### Q: 如何回滚到之前的版本？

A:
```bash
# 查看提交历史
git log --oneline wiki-integration/main

# 回滚到特定提交
git checkout <commit-hash>

# 或者重置分支
git reset --hard HEAD~1
git push origin wiki-integration/main --force
```

---

## 📊 分支说明

| 分支 | 用途 | 更新频率 |
|------|------|---------|
| `main` | 跟踪上游 | 每周同步 |
| `wiki-integration/main` | 日常工作分支 | 持续使用 |
| `feature/llm-wiki-integration` | PR 分支 | 仅用于 PR |

---

## 🔗 有用链接

- **你的 Fork:** https://github.com/liqunx/OpenSpec
- **上游仓库:** https://github.com/Fission-AI/OpenSpec
- **PR 状态:** 等待审查
- **完整文档:** [WIKI-INTEGRATION-MAINTENANCE.md](WIKI-INTEGRATION-MAINTENANCE.md)

---

## 💡 提示

1. **定期同步** - 每周同步一次，避免大量冲突
2. **备份重要更改** - 推送前确保代码工作正常
3. **测试驱动** - 每次同步后运行测试
4. **阅读变更日志** - 了解上游的重要变化

---

**最后更新:** 2026-04-22  
**维护者:** liqunx
