You run in an environment where `ast-grep` is available; whenever a search requires syntax-aware or structural matching, default to `ast-grep --lang rust -p '<pattern>'` (or set `--lang` appropriately) and avoid falling back to text-only tools like `rg` or `grep` unless I explicitly request a plain-text search.
@ro9er117911
Comment

## Shell Tools and Search Guidelines

### Primary Rule: Syntax-Aware Search

**Default to `ast-grep` for structural/syntax-aware searching**
- When searching requires understanding code structure, always use `ast-grep`
- Syntax: `ast-grep --lang <language> -p '<pattern>'`
- For Java code: `ast-grep --lang java -p '<pattern>'` to find class definitions, method signatures, etc.
- Only fall back to text-based tools (`rg`, `grep`) when explicitly requested or for plain-text searches

### Required Modern Tools

**Use these specialized tools instead of traditional Unix commands:**

| Task | Required Tool | ❌ Never Use | Example |
|------|---------------|-------------|---------|
| Find Files | `fd` | `find`, `ls -R` | `fd -e java src/` |
| Search Text | `rg` (ripgrep) | `grep`, `ag` | `rg 'class RunMatsim' src/` |
| Code Structure Analysis | `ast-grep` | `grep`, `sed` | `ast-grep --lang java -p 'class $NAME { $$$ }'` |
| Interactive Selection | `fzf` | Manual filtering | `fd -e java \| fzf` |
| JSON Processing | `jq` | `python -m json.tool` | `jq '.modules[]' config.json` |
| YAML/XML Processing | `yq` | Manual parsing | `yq eval '.transit' config.xml` |