# Critical Rules for Claude Code

## Never

- Never hardcode design values (colors, fonts, spacing) during Phase 1. Use placeholder tokens or system defaults.
- Never include AI disclaimers in commits. No "Co-Authored-By: Claude", "Generated with Claude Code", or similar.
- Never commit credentials. API keys and tokens go in environment variables.
- Never edit bundled JSON directly for content updates. Use the curation scripts in `scripts/`.
- Never skip Xcode Preview testing. Verify changes render correctly.

## Always

- Always use SwiftUI standard components until Phase 2 design application.
- Always update ARCHITECTURE.md when patterns or components change.

## Documentation Boundaries

**ARCHITECTURE.md** contains:
- Technical decisions and rationale.
- Data schemas and structures.
- Component patterns and data flow.
- Forward-looking roadmap (what's next).

**ARCHITECTURE.md must NOT contain:**
- Specific counts or statistics from script runs.
- Progress checkmarks or completion status.
- Session outputs or historical reports.

**OVERVIEW.md** may contain:
- Aspirational targets (e.g., "1,000+ items", "~20 fonts").
- Scope estimates (e.g., "Phase 1 (~80%)").
- Success criteria with specific goals.

These are product requirements, not statistics from actual runs.

**General principle:** Documentation describes *what the system is* and *what we're building toward*, not *how we got here*.

## Responsive Layout

- Design for portrait orientation first.
- Constrain content to readable width on larger screens (don't stretch edge-to-edge).
- Use SwiftUI's adaptive layout (`.frame(maxWidth:)`, `ViewThatFits`, etc.).
- Test on both iPhone and iPad simulators.

## Conventions

### Naming

- Views: `[Name]View.swift` (e.g., `PracticeView.swift`).
- Models: `[Name].swift` (e.g., `Word.swift`).
- Services: `[Name]Service.swift` (e.g., `ContentService.swift`).

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
