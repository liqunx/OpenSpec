# Lingma IDE 配置指南

## Lingma IDE 是否支持 Hooks？

**答案：不支持**

Lingma IDE 目前不支持 Claude Code 的 `PreToolUse` 和 `PostToolUse` hooks 机制。

`settings.json` 中的 hooks 配置在 Lingma IDE 中**无效**。

---

## 替代方案

### 方案 1：手动调用技能（推荐）⭐

由于 Lingma IDE 不支持自动化 hooks，你需要手动调用 wiki 技能：

#### 工作流程

```bash
# 1. 开始探索或提案前，手动查询 wiki
/openspec-wiki-query

# 2. 然后正常进行
/openspec-explore "your idea"
# 或
/openspec-propose "your idea"

# 3. 完成工作后归档
/openspec-archive-change

# 4. 归档后，手动 ingest 到 wiki
/openspec-wiki-ingest
```

#### 养成习惯

建议在团队中建立以下习惯：
- 在开始任何新功能前，先运行 `/openspec-wiki-query`
- 在完成并归档后，立即运行 `/openspec-wiki-ingest`
- 可以将这两个命令添加到团队的开发规范中

---

### 方案 2：使用 Lingma IDE 的 Rules 功能

Lingma IDE 支持"自定义项目专属规则"，可以在特定场景下自动生效。

#### 配置步骤

1. **打开个人设置**
   - macOS: `⌘ ⇧ ,`
   - Windows: `Ctrl Shift ,`

2. **导航到规则**
   - 左侧导航栏点击 "规则"
   - 点击 "添加"

3. **创建 Wiki Query 规则**

   ```
   规则名称: openspec-wiki-query-reminder
   规则类型: 模型决策
   场景描述: 当用户执行 openspec-explore 或 openspec-propose 时，提醒先查询 wiki
   ```

   **规则内容：**
   ```markdown
   在执行 openspec-explore 或 openspec-propose 之前，建议先运行 /openspec-wiki-query 
   来了解相关背景信息和已有功能，避免重复工作。
   
   你可以这样做：
   1. 先运行: /openspec-wiki-query {你的主题}
   2. 查看返回的相关页面和设计决策
   3. 然后再开始 explore 或 propose
   ```

4. **创建 Wiki Ingest 规则**

   ```
   规则名称: openspec-wiki-ingest-reminder
   规则类型: 模型决策
   场景描述: 当用户执行 openspec-archive-change 后，提醒 ingest 到 wiki
   ```

   **规则内容：**
   ```markdown
   在执行 openspec-archive-change 归档变更之后，建议运行 /openspec-wiki-ingest 
   将变更文档摄入到 wiki 中，保持知识库更新。
   
   你可以这样做：
   1. 归档完成后，运行: /openspec-wiki-ingest
   2. 或者指定具体变更: /openspec-wiki-ingest openspec/changes/archive/{变更名}
   3. 确认 wiki 页面已正确创建/更新
   ```

#### 规则类型说明

- **手动引入**：仅通过 `@rule` 手动引入才生效
- **模型决策**：AI 根据场景描述自动判断何时应用规则
- **指定文件生效**：在特定文件路径下生效
- **始终生效**：在所有请求中均生效

**推荐使用"模型决策"类型**，让 AI 智能判断何时提醒你。

---

### 方案 3：创建快捷命令脚本

创建一个简单的脚本来自动化整个流程：

#### Windows PowerShell: `scripts/openspec-workflow.ps1`

```powershell
# OpenSpec Workflow Helper for Lingma IDE
# This script helps you follow the wiki integration workflow

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    
    [string]$ChangeName
)

switch ($Action) {
    "start" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  Starting New Change with Wiki Query" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Before you start, remember to:" -ForegroundColor Yellow
        Write-Host "  1. Run: /openspec-wiki-query {your-topic}" -ForegroundColor Green
        Write-Host "  2. Review the results" -ForegroundColor Green
        Write-Host "  3. Then run: /openspec-propose {your-idea}" -ForegroundColor Green
        Write-Host ""
        Write-Host "This helps you avoid duplicate work and leverage existing knowledge." -ForegroundColor Gray
        Write-Host ""
    }
    
    "finish" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  Completing Change with Wiki Ingest" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        
        if ($ChangeName) {
            Write-Host "After archiving, remember to:" -ForegroundColor Yellow
            Write-Host "  1. Run: /openspec-wiki-ingest openspec/changes/archive/$ChangeName" -ForegroundColor Green
            Write-Host "  2. Verify the wiki page was created" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host "After archiving, remember to:" -ForegroundColor Yellow
            Write-Host "  1. Run: /openspec-wiki-ingest" -ForegroundColor Green
            Write-Host "     (auto-detects unprocessed changes)" -ForegroundColor Gray
            Write-Host "  2. Verify the wiki page was created" -ForegroundColor Green
            Write-Host ""
        }
        
        Write-Host "This keeps your knowledge base up to date!" -ForegroundColor Gray
        Write-Host ""
    }
    
    default {
        Write-Host "Usage:" -ForegroundColor Red
        Write-Host "  .\openspec-workflow.ps1 -Action start" -ForegroundColor Yellow
        Write-Host "  .\openspec-workflow.ps1 -Action finish [-ChangeName <name>]" -ForegroundColor Yellow
        Write-Host ""
    }
}
```

**使用方法：**

```powershell
# 开始新变更前
.\scripts\openspec-workflow.ps1 -Action start

# 完成变更后
.\scripts\openspec-workflow.ps1 -Action finish -ChangeName add-auth-system
```

---

### 方案 4：团队规范和文档

如果是在团队中使用，可以通过以下方式确保大家遵循工作流：

#### 1. 创建团队开发规范文档

在项目根目录创建 `DEVELOPMENT-WORKFLOW.md`：

```markdown
# Development Workflow with Wiki Integration

## Before Starting a New Feature

1. **Query the Wiki** (MANDATORY)
   ```bash
   /openspec-wiki-query {feature-name}
   ```
   - Check for existing similar features
   - Review related design decisions
   - Understand the context

2. **Then Start Your Work**
   ```bash
   /openspec-propose "your idea"
   ```

## After Completing a Change

1. **Archive the Change**
   ```bash
   /openspec-archive-change
   ```

2. **Ingest to Wiki** (MANDATORY)
   ```bash
   /openspec-wiki-ingest
   ```
   - Verify the wiki page was created
   - Check for any conflicts or issues
   - Add missing cross-references if needed

## Why This Matters

- Avoids duplicate work
- Maintains project knowledge
- Helps team members understand past decisions
- Makes onboarding easier

## Checklist

Before submitting a PR:
- [ ] Queried wiki before starting
- [ ] Archived the change
- [ ] Ingested to wiki
- [ ] Verified wiki page accuracy
```

#### 2. Code Review Checklist

在 PR 模板中添加检查项：

```markdown
## Wiki Integration Checklist

- [ ] Ran `/openspec-wiki-query` before starting
- [ ] Ran `/openspec-wiki-ingest` after archiving
- [ ] Verified wiki page is accurate
- [ ] Added relevant cross-references
```

#### 3. Team Training

- 在团队会议上演示完整工作流
- 录制视频教程
- 分享最佳实践

---

## 各 IDE 支持情况对比

| IDE | Hooks 支持 | 替代方案 | 推荐程度 |
|-----|-----------|---------|---------|
| **Claude Code** | ✅ 完整支持 | - | ⭐⭐⭐⭐⭐ |
| **Lingma IDE** | ❌ 不支持 | Rules + 手动调用 | ⭐⭐⭐ |
| **Cursor** | ❓ 未知 | 待验证 | - |
| **Windsurf** | ❓ 未知 | 待验证 | - |
| **VS Code + Extension** | ❌ 不支持 | 手动调用 | ⭐⭐ |

---

## 最佳实践建议

### 对于 Lingma IDE 用户

1. **养成手动调用的习惯**
   - 将 `/openspec-wiki-query` 和 `/openspec-wiki-ingest` 作为标准流程的一部分
   - 设置 IDE 提醒或便签

2. **使用 Rules 功能**
   - 配置智能提醒规则
   - 让 AI 在你可能忘记时提醒你

3. **团队规范**
   - 将 wiki 集成纳入开发流程
   - Code review 时检查是否执行

4. **文档化**
   - 在项目中明确说明工作流
   - 新人入职时培训

### 通用建议

无论使用哪个 IDE：

1. **保持一致性**
   - 团队成员使用相同的工作流
   - 定期检查和更新 wiki

2. **质量优先**
   - 不要为了自动化而牺牲质量
   - 手动检查生成的 wiki 页面

3. **持续改进**
   - 收集团队反馈
   - 优化工作流程

---

## 总结

**Lingma IDE 不支持 Claude Code 的 hooks 机制**，但你仍然可以使用 LLM Wiki 集成功能：

✅ **推荐方案**：
1. 手动调用 `/openspec-wiki-query` 和 `/openspec-wiki-ingest`
2. 使用 Lingma IDE 的 Rules 功能设置提醒
3. 建立团队规范和文档
4. 养成良好习惯

虽然不如 Claude Code 的自动化方便，但通过良好的习惯和规范，同样可以达到很好的效果！

---

**最后更新:** 2026-04-22  
**适用 IDE:** Lingma IDE  
**状态:** 已验证不支持 hooks
