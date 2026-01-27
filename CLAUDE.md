# Critical Rules for Claude Code

- Never hardcode design values (colors, fonts, spacing) during Phase 1. Use placeholder tokens or system defaults.
- Never include AI disclaimers in commits. No "Co-Authored-By: Claude", "Generated with Claude Code", or similar.
- For content changes, update `data/words.json` via the curation scripts in `scripts/`.

## MCP Tools

### sosumi (Apple Developer Documentation)

Use the `sosumi` MCP server to access Apple Developer documentation. Apple's documentation pages are JavaScript-rendered and cannot be fetched with standard web tools.

**Available tools:**
- `mcp__sosumi__searchAppleDocumentation` - Search Apple docs by query
- `mcp__sosumi__fetchAppleDocumentation` - Fetch a specific documentation page by path

**Examples:**
```
# Search for documentation
mcp__sosumi__searchAppleDocumentation(query: "SwiftUI State")

# Fetch a specific page
mcp__sosumi__fetchAppleDocumentation(path: "/documentation/swift/array")
mcp__sosumi__fetchAppleDocumentation(path: "/documentation/swiftui/view")
mcp__sosumi__fetchAppleDocumentation(path: "design/human-interface-guidelines/foundations/color")
```

Use sosumi whenever you need to reference Apple documentation for Swift, SwiftUI, UIKit, or any Apple framework.
