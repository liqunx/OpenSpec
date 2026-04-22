# LLM Wiki Integration Examples

This directory contains example configurations and skills for integrating OpenSpec with LLM Wiki for knowledge management.

## Contents

### `skills/` - For Claude Code
Example skill files that can be copied to your project's AI tool directory:

- **`openspec-wiki-query/`** - Skill for querying the wiki before starting work
- **`openspec-wiki-ingest/`** - Skill for ingesting completed changes into the wiki

### `claude-settings.json`
Example hook configuration for Claude Code that automatically triggers wiki query and ingest operations.

### `lingma-commands/` - For Lingma IDE ⭐
Command files specifically designed for Lingma IDE:

- **`opsx/wiki-query.md`** - Command: `/opsx:wiki-query`
- **`opsx/wiki-ingest.md`** - Command: `/opsx:wiki-ingest`
- **`README.md`** - Lingma IDE specific setup guide

**Note**: Lingma IDE does not support hooks, so these are manual commands instead of automated skills.

## Quick Setup

### For Claude Code

1. Copy skills to your AI tool directory:
   ```bash
   cp -r skills/openspec-wiki-query .claude/skills/
   cp -r skills/openspec-wiki-ingest .claude/skills/
   ```

2. Configure hooks (see `claude-settings.json` for example)

3. Initialize wiki structure in your project:
   ```bash
   mkdir -p openspec/docs/wiki/features
   mkdir -p openspec/docs/raw/00-uncategorized
   mkdir -p openspec/docs/schema
   ```

4. Restart your IDE

### For Lingma IDE

1. Copy commands to your Lingma commands directory:
   ```bash
   cp lingma-commands/opsx/wiki-query.md .lingma/commands/opsx/
   cp lingma-commands/opsx/wiki-ingest.md .lingma/commands/opsx/
   ```

2. Initialize wiki structure (same as above)

3. Restart Lingma IDE

4. Use manually:
   ```bash
   # Before work
   /opsx:wiki-query {topic}
   
   # After archiving
   /opsx:wiki-ingest
   ```

For detailed instructions, see [docs/guides/llm-wiki-integration.md](../../docs/guides/llm-wiki-integration.md).

## Directory Structure

The recommended wiki structure uses `openspec/docs/` as the base:

```
openspec/
├── docs/
│   ├── wiki/              # Knowledge base
│   │   ├── index.md
│   │   ├── log.md
│   │   ├── features/
│   │   ├── components/
│   │   └── ...
│   ├── raw/               # Source documents
│   │   ├── 00-meta/
│   │   ├── 00-uncategorized/
│   │   └── 05-configurations/
│   └── schema/            # Schema definitions
│       └── CLAUDE.md
```

## Customization

These examples are generic and should be customized for your project:

- Adjust wiki paths if using different structure
- Modify exclusion rules in schema file
- Customize page templates
- Adapt hook configuration for your IDE

## Notes

- Skills use `openspec/docs/` as the default wiki location
- Hooks are configured for Claude Code; adapt for other tools
- All content is in English for international compatibility
- Skills read from actual files, not hardcoded content
