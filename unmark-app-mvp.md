# Unmark — macOS Menu Bar App MVP

## Vision
Dead-simple Markdown → Rich Text converter. Click menu bar icon, paste Markdown, auto-copy formatted text. No friction, no dialogs.

## Core Flow

### User Journey
1. **Click menu bar icon** → Popover window appears (small, fixed size)
2. **Paste Markdown** into text box
3. **Auto-convert** to Rich Text (NSAttributedString)
4. **Auto-copy** to clipboard
5. **Visual confirmation** → "Copied to clipboard" message appears in same window
6. **Click elsewhere** → Popover closes

### Window Layout
```
┌─────────────────────────────┐
│                             │
│  [Markdown Input Box]       │
│  (multi-line text area)     │
│                             │
│  ─────────────────────────  │
│  Will convert automatically │
│  to: [Rich Text ▼]          │
│                             │
│  Copied to clipboard ✓      │ ← appears after copy, fades after 1.5s
└─────────────────────────────┘
```

**Window Properties:**
- **Size**: Fixed 400px × 300px (popover)
- **Position**: Anchored below menu bar icon
- **Behavior**: Click outside to close, auto-hide on copy + 2s delay
- **Always on top**: Yes, but respects Command+Tab window switching

## Feature Set (MVP)

### Phase 1: Markdown → Rich Text (Only)
- [x] Menu bar icon + popover
- [x] Textarea for Markdown input
- [x] Real-time conversion (as user types)
- [x] Auto-copy to clipboard on change
- [x] "Copied to clipboard" indicator (1.5s fade)
- [x] Format selector dropdown (single option: "Rich Text")

### Phase 2: Future Expansion (Post-MVP)
- [ ] HTML output format
- [ ] Plain text output format  
- [ ] Format selector becomes functional
- [ ] User preferences (dark mode, font size)

## Technical Stack
- **Language**: Swift + SwiftUI
- **Dependencies**: 
  - `swift-markdown` or `Down` (Markdown parsing)
  - AppKit for clipboard operations
  - Nothing else
- **Minimum OS**: macOS 12 Monterey
- **Code Signing**: Notarization for App Store

## Implementation Details

### Popover Management
```swift
// Menu bar app pattern
@main
struct UnmarkApp: App {
    @State private var showPopover = false
    
    var body: some Scene {
        MenuBarExtra("Unmark", systemImage: "doc.richtext") {
            ConverterView(showPopover: $showPopover)
        }
        .menuBarExtraStyle(.window)
    }
}
```

### Markdown Conversion
```swift
// Real-time conversion
@State private var markdown = ""
@State private var showCopiedAlert = false

var body: some View {
    TextEditor(text: $markdown)
        .onChange(of: markdown) { newValue in
            let richText = convertMarkdownToRichText(newValue)
            copyToClipboard(richText)
            showCopiedAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCopiedAlert = false
            }
        }
}
```

### Clipboard Operations
- Read from clipboard (optional, for user's convenience)
- Write NSAttributedString to pasteboard as RTF
- Fallback to plain text if RTF fails

## Design Notes

### Keep It Simple
- No settings panel (for MVP)
- No history or favorites
- No export options (clipboard is the output)
- No advanced Markdown features (just core: headings, bold, italic, code, lists)
- One format selector, zero choices (for MVP)

### UX Constraints
- Popover must not steal focus from current app
- Copy must happen automatically (no button click)
- Visual feedback is text-only: "Copied to clipboard" (no popup notification)
- Auto-close after 3 seconds of inactivity (optional, test in beta)

### Styling
- Light mode: Clean white/gray UI
- Dark mode: Respect system setting
- Font: System font (SF Pro)
- Colors: Minimal, match macOS aesthetic

## Success Criteria (MVP)
- [x] Menu bar icon + popover in place
- [x] Markdown textarea functional
- [x] Real-time conversion works
- [x] Auto-copy to clipboard
- [x] "Copied to clipboard" indicator (no popup)
- [x] Format selector shows "Rich Text" (placeholder for future)
- [x] App launches in < 300ms
- [x] Conversion < 50ms
- [ ] Zero crashes
- [ ] App Store submission-ready

## What's NOT in MVP
- ❌ Keyboard shortcuts (future)
- ❌ Multiple output formats
- ❌ User preferences/settings
- ❌ History or saved conversions
- ❌ Markdown preview pane
- ❌ Custom styling/themes
- ❌ Export to file

## Next Steps
1. Set up Xcode project (SwiftUI menu bar app template)
2. Implement basic popover + textarea
3. Add Markdown parser dependency
4. Build rich text conversion
5. Test clipboard operations
6. Polish UI and submit to App Store

---

**Registry**: unmark.app (domain TBD - confirm availability)  
**Target Launch**: MVP in 2-4 weeks  
**Platform**: macOS 12+ (App Store + DMG)
