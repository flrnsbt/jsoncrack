---
sessionId: session-261023-015944-19p1
---

# Requirements

### Overview
Regenerate the `README.md` for the `jsoncrack` Flutter package to be a complete, up-to-date documentation file that reflects all current features, customization options, and includes proper copyright attribution and a demo app link.

### Current State
- The existing README only documents 2 options (`layoutDirection`, `showGrid`) but the package now has 6 options.
- The `LICENSE` file is a placeholder (`TODO: Add your license here`).
- No copyright attribution or demo app link exists in the README.

### Goals
- Update the README to reflect all 5 customization options (`layoutDirection`, `showGrid`, `showControls`, `centerOnLayout`, `maxRenderableNodes`).
- Add copyright notice: `© 2025 floriansabate.top`.
- Add a link to the demo app: `https://jsoncrack-bdf.pages.dev`.
- Update the example section to mention responsive mobile support.
- Update the LICENSE file with a proper copyright notice.
- Ensure the README is comprehensive and matches the current package version (0.2.0).

# Technical Design

### Current Implementation
- **`README.md`**: 210 lines, covers basic usage, options table (2 options only), architecture, example project, and requirements.
- **`LICENSE`**: Placeholder text only.
- **`lib/src/options.dart`**: Contains 6 options with full documentation.
- **`CHANGELOG.md`**: Documents versions 0.1.0 and 0.2.0.
- **`pubspec.yaml`**: Version 0.2.0, description, and dependencies.

### Proposed Changes

**`README.md`** — Full regeneration:
- Add badge-like header with package name, description, and demo link.
- Update the **Features** section to include all 6 customization options.
- Update the **Available options** table to include all 6 options with types, defaults, and descriptions.
- Add a **Customization** section with examples for the new options (`showControls`, `centerOnLayout`, `maxRenderableNodes`).
- Update the **Example project** section to mention responsive mobile support (narrow layout, drawer, bottom sheet editor).
- Add **Copyright** section: `© 2025 floriansabate.top`.
- Add **Demo** link: `https://jsoncrack-bdf.pages.dev`.
- Keep existing sections: Getting Started, Usage, Architecture, Requirements.

**`LICENSE`** — Update with copyright:
- Replace placeholder with a simple copyright notice referencing `floriansabate.top`.

# Delivery Steps

### ✓ Step 1: Update LICENSE with copyright
Replace the placeholder LICENSE with a proper copyright notice.
- Update `LICENSE` to include `© 2025 floriansabate.top` with a permissive license text (MIT-style).

### ✓ Step 2: Regenerate complete README
Rewrite `README.md` to be comprehensive and up-to-date.
- Add demo app link (`https://jsoncrack-bdf.pages.dev`) in the header and a dedicated Demo section.
- Update Features section to list all 6 customization options.
- Update the Available options table with all options: `layoutDirection`, `showGrid`, `showControls`, `centerOnLayout`, `maxRenderableNodes`.
- Add a Customization section with code examples for new options.
- Update the Example project section to mention responsive mobile support.
- Add copyright notice: `© 2025 floriansabate.top`.
- Ensure consistency with `pubspec.yaml` version (0.2.0) and `CHANGELOG.md`.