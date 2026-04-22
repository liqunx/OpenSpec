# LLM Wiki Integration for Lingma IDE

This directory contains command files specifically designed for **Lingma IDE**.

## Key Differences from Claude Code

### Claude Code
- Uses **Skills** + **Hooks** (settings.json)
- Automatic triggering via PreToolUse/PostToolUse hooks
- Configuration: `claude-settings.json`

### Lingma IDE
- Uses **Commands** in `.lingma/commands/opsx/` directory
- Manual invocation via `/opsx:wiki-query` and `/opsx:wiki-ingest`
- No hooks support - users must manually call commands
- Configuration: Copy commands to your project's `.lingma/commands/opsx/`

---

## Installation

### Step 1: Copy Command Files

```bash
# Copy to your project's Lingma commands directory
cp examples/wiki-integration/lingma-commands/opsx/wiki-query.md .lingma/commands/opsx/
cp examples/wiki-integration/lingma-commands/opsx/wiki-ingest.md .lingma/commands/opsx/
```

### Step 2: Initialize Wiki Structure

```bash
mkdir -p openspec/docs/wiki/features
mkdir -p openspec/docs/raw/00-uncategorized
mkdir -p openspec/docs/schema
```

Create initial files:
- `openspec/docs/wiki/index.md`
- `openspec/docs/wiki/log.md`
- `openspec/docs/schema/CLAUDE.md`

### Step 3: Restart Lingma IDE

Restart your IDE to load the new commands.

---

## Usage

### Before Starting Work

```bash
# Query wiki for context
/opsx:wiki-query {topic}

# Then start exploration or proposal
/opsx:explore {topic}
# or
/opsx:propose {idea}
```

### After Completing Work

```bash
# Archive the change
/opsx:archive

# Ingest to wiki
/opsx:wiki-ingest
```

---

## Available Commands

### `/opsx:wiki-query [topic]`

Query the wiki for relevant information before starting work.

**Parameters**:
- `topic` (optional): What to search for. If not provided, infers from context.

**Example**:
```bash
/opsx:wiki-query authentication
/opsx:wiki-query database migration
```

### `/opsx:wiki-ingest [path]`

Ingest completed changes into the wiki after archiving.

**Parameters**:
- `path` (optional): Specific change or document to ingest. If not provided, auto-detects all unprocessed changes.

**Examples**:
```bash
# Auto-detect and batch ingest
/opsx:wiki-ingest

# Ingest specific change
/opsx:wiki-ingest add-auth-system

# Ingest specific document
/opsx:wiki-ingest openspec/docs/raw/guides/api-design.md
```

---

## Workflow Example

### Complete Change Lifecycle

```bash
# 1. Start: Query wiki for context
/opsx:wiki-query user authentication

# 2. Explore or propose
/opsx:propose "Add OAuth2 authentication"

# 3. Implement (using other opsx commands)
/opsx:apply

# 4. Complete and archive
/opsx:archive

# 5. Ingest to wiki
/opsx:wiki-ingest
```

---

## Comparison: Claude Code vs Lingma IDE

| Feature | Claude Code | Lingma IDE |
|---------|-------------|------------|
| **Format** | Skills + Hooks | Commands |
| **Location** | `.claude/skills/` | `.lingma/commands/opsx/` |
| **Invocation** | Automatic (hooks) | Manual (`/opsx:wiki-*`) |
| **Configuration** | `settings.json` | None (manual workflow) |
| **Automation** | ✅ Full | ❌ Manual |
| **Setup Complexity** | Medium | Low |

---

## Tips for Lingma IDE Users

### 1. Create Habits

Since there's no automation, build these habits:
- **Always** query wiki before starting new work
- **Always** ingest after archiving
- Add reminders to your workflow checklist

### 2. Use Lingma IDE Rules

You can configure reminder rules in Lingma IDE:

1. Open Personal Settings: `Ctrl Shift ,`
2. Navigate to "Rules"
3. Add a rule with model decision type:
   ```
   When user runs /opsx:explore or /opsx:propose, 
   remind them to first run /opsx:wiki-query
   ```

### 3. Team Conventions

If working in a team:
- Document the manual workflow
- Include wiki steps in code review checklist
- Train new team members on the process

---

## Troubleshooting

### Commands Not Recognized

**Problem**: `/opsx:wiki-query` returns "command not found"

**Solution**:
1. Verify files are in `.lingma/commands/opsx/`
2. Check file names end with `.md`
3. Verify YAML frontmatter is valid
4. Restart Lingma IDE

### Wiki Not Found

**Problem**: Commands report "Wiki structure not initialized"

**Solution**:
1. Ensure `openspec/docs/wiki/index.md` exists
2. Create required directory structure
3. Refer to main integration guide

---

## Related Documentation

- [Main Integration Guide](../../docs/guides/llm-wiki-integration.md)
- [Lingma IDE Configuration](../../LINGMA-IDE-CONFIG.md)
- [Quick Reference](../../QUICK-REFERENCE.md)

---

## Notes

- These commands use the same logic as Claude Code skills
- Only the invocation method differs (manual vs automatic)
- All paths use `openspec/docs/` structure
- Commands read from actual files, not hardcoded content
