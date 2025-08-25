# APGIntentKit

A lightweight Swift package for **standardizing UI commands** (menu items, toolbar items, buttons) around a simple **Intent** model.  
It separates **what the UI shows** (name, hint, icon, shortcut) from **what it does** (closure to invoke, enable/disable, checkmark, and dynamic title), so you can declare commands once and reuse them across UI surfaces.

Repository https://github.com/magesteve/APGIntentKit with current version **0.4.0**

- **Info** (`APGIntentInfo`) → UI-facing metadata (name, hint, SF Symbol, shortcut).
- **Action** (`APGIntentAction`) → Behavior & appearance (perform closure + appearance closure).
- **Adapters (macOS)** → `NSMenuItem`, `NSToolbarItem`, and `NSButton` that bind to intents.

> **Status:** macOS-focused, designed to expand to other Apple platforms.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Concepts](#concepts)
- [Quick Start](#quick-start)
- [Registering Info](#registering-info)
- [Registering Actions](#registering-actions)
- [Using With Menus](#using-with-menus)
- [Using With Toolbars](#using-with-toolbars)
- [Using With Buttons](#using-with-buttons)
- [Window vs App Scope](#window-vs-app-scope)
- [Validation & Dynamic Appearance](#validation--dynamic-appearance)
- [Threading & Actors](#threading--actors)
- [Token Conventions](#token-conventions)
- [FAQ](#faq)
- [Sample Code](#sample-code)
- [License](#license)

---

## Features

- **Single source of truth** for command metadata (name, long/short labels, hint/description, SF Symbol, key equivalents).
- **Behavior & appearance logic** (enable/disable, checkmark state, dynamic title) defined alongside the action.
- **Drop-in macOS UI adapters**:
  - `APGIntentMenuItem` (validates via `NSMenuItemValidation`)
  - `APGIntentToolbarItem` (validates via `NSToolbarItem.validate()`)
  - `APGIntentMacButton` (validates on demand)
- **Global (app-level) & window-local** action registries, with sensible shadowing rules.

---

## Installation

Add to your Package.swift:

```swift
.package(url: "https://github.com/your-org/APGIntentKit.git", from: "0.3.0")
```

Then add `"APGIntentKit"` to your target dependencies.

**Minimum**: macOS 11+ (SF Symbols in toolbar items require 11+).  
The macOS adapters are wrapped in `#if os(macOS)`.

---

## Concepts

### APGIntentInfo (UI metadata)

```swift
public struct APGIntentInfo: Hashable, Sendable {
    public let token: String
    public let name: String
    public let alwaysOn: Bool
    public let shortName: String?
    public let longName: String?
    public let description: String?
    public let hint: String?
    public let symbolName: String?
    public let menuKey: String?
}
```

- `token` is the unique ID and joins UI/adapters to your behavior.
- `alwaysOn` skips validation (useful for About/Help, etc.).
- `shortName`/`longName` feed toolbars/palette.
- `symbolName` should be an SF Symbol (e.g. `"lightbulb"`).
- `menuKey` sets a ⌘ key equivalent on `APGIntentMenuItem`.

### APGIntentAction (behavior & appearance)

```swift
public typealias APGIntentActionClosure = @Sendable @MainActor (String) -> Void
public typealias APGIntentAppearanceClosure = @Sendable (String) -> (Bool, Bool?, String?)
```

- Both closures receive a **`param: String`** (e.g., document ID, selection key, mode).
- Appearance returns:
  - `enabled: Bool`
  - `isChecked: Bool?` (nil = no checkmark)
  - `overriddenTitle: String?` (nil = keep default label)

---

## Quick Start

### 1) Register Info (UI metadata)

```swift
APGIntentInfoList.shared.add(contentsOf: [
    APGIntentInfo(token: "about",
                  name: "About My App",
                  symbolName: "questionmark.circle"),
    APGIntentInfo(token: "faq",
                  name: "FAQ",
                  symbolName: "book"),
    APGIntentInfo(token: "bulb.toggle",
                  name: "Bulb",
                  symbolName: "lightbulb",
                  menuKey: "1",
                  alwaysOn: false)
])
```

### 2) Register **App-level** Actions

```swift
APGIntentActionList.sharedApp.addAction(token: "about") { _ in
    // Show About window
}
APGIntentActionList.sharedApp.addAction(token: "faq") { _ in
    // Show FAQ window
}
```

### 3) Register **Window-level** Actions (with param & appearance)

```swift
// e.g., inside a view controller that owns `fBulbOn` state
guard let helper = findIntentHelper(for: self) else { return }

helper.addWindowAction(
    token: "bulb.toggle",
    action: { param in
        // param might be a context string, e.g. "primary" vs "secondary"
        fBulbOn.toggle()
    },
    appearance: { param in
        // Enabled if param matches expected context
        let enabled = (param.isEmpty || param == "primary")
        // Checked if bulb is on; no overridden title
        return (enabled, fBulbOn, nil)
    }
)
```

### 4) Use in Menus

```swift
APGIntentMacTools.addAppMenuIntents(about: ["about"], settings: [])
APGIntentMacTools.addMenuBeforeHelp(named: "Tools", tokens: ["bulb.toggle"])
```

If you need to pass a parameter, you can create and add items yourself:

```swift
#if os(macOS)
let item = APGIntentMenuItem(token: "bulb.toggle", param: "primary")
NSApp.mainMenu?.item(withTitle: "Tools")?.submenu?.addItem(item)
#endif
```

### 5) Use in Toolbars

```swift
guard let helper = findIntentHelper(for: self) else { return }
helper.addIntentToolbar(unique: "mywindow",
                        defaults: ["bulb.toggle"],
                        extras: ["about", "faq"])
```

### 6) Use in Buttons (AppKit)

```swift
#if os(macOS)
let aboutButton = APGIntentMacButton(token: "about")
let bulbButton  = APGIntentMacButton(token: "bulb.toggle", param: "primary")
#endif
```

---

## Registering Info

Keep all your visible command metadata in one place:

```swift
APGIntentInfoList.shared.add(
    APGIntentInfo(token: "file.new",
                  name: "New Document",
                  shortName: "New",
                  description: "Create a new document",
                  symbolName: "doc.badge.plus",
                  menuKey: "n")
)
```

Each `APGIntentInfo` defines **what the UI shows** for a command.  
It does not perform logic — it only carries user-facing metadata (names, tooltips, icons, shortcuts).

---

## Registering Actions

You can attach actions globally (app scope) **or** to a window (window scope).  
Window scope shadows app scope for the same token.

**App scope:**
```swift
APGIntentActionList.sharedApp.addAction(token: "file.new") { param in
    // Create document, maybe param encodes a template kind
}
```

**Window scope:**
```swift
helper.addWindowAction(token: "edit.copy") { param in
    // Copy from this window’s selection
}
```

With appearance:

```swift
helper.addWindowAction(
    token: "view.zoomIn",
    action: { _ in zoomIn() },
    appearance: { _ in
        let canZoomIn = zoomLevel < 400
        return (canZoomIn, nil, nil)
    }
)
```

---

## Using With Menus

- Add items to the App menu / a custom menu / Help menu via `APGIntentMacTools`.
- Or instantiate `APGIntentMenuItem(token:param:)` yourself for full control.

```swift
APGIntentMacTools.addHelpMenuIntents(help: ["faq"])
```

Validation is automatic via `NSMenuItemValidation`.  
If your `APGIntentInfo.alwaysOn` is `true`, the item remains enabled without calling `appearance`.

---

## Using With Toolbars

Attach a toolbar that is automatically populated with your intent items:

```swift
helper.addIntentToolbar(unique: "documentWindow",
                        defaults: ["view.zoomIn", "view.zoomOut"],
                        extras: ["about", "faq"])
```

- Items are identified as `"apgintent-" + token`.
- `APGIntentToolbarItem` calls your `appearance(param)` on `validate()` and updates:
  - enabled/disabled
  - checkmark state (via alternate filled SF Symbol name)
  - optional overridden label

---

## Using With Buttons

`APGIntentMacButton` forwards its `token` and `param` to your action/appearance:

```swift
let runButton = APGIntentMacButton(token: "build.run")
runButton.param = "release"
// Optional: call `intentValidateUI()` if your UI needs to refresh title/state immediately.
```

---

## Window vs App Scope

- **Window-local** actions live in the window’s `APGIntentMacWindowHelper`.
- **App-global** actions live in `APGIntentActionList.sharedApp`.
- Lookup order is **window first**, then **app**.  
  This allows document windows to override behavior while keeping app-wide fallbacks.

Helpers:

```swift
APGIntentMacWindowHelper.findTopmostActionInfo(token: "file.save")
APGIntentMacWindowHelper.findWindowActionInfo(window: window, token: "file.save")
```

---

## Validation & Dynamic Appearance

Your `appearance(param)` decides if a command is available and how it looks:

```swift
appearance: { param in
    let enabled = selectionCount > 0
    let checked  = isPinned(selection)
    let title    = selectionCount == 1 ? "Pin Item" : "Pin \(selectionCount) Items"
    return (enabled, checked, title)
}
```

- `enabled == false` disables the UI surface.
- `checked == true` draws a checkmark (menus) or uses a “.fill” variant of your symbol (toolbars).
- `title` lets you change the visible label dynamically (toolbars/menus).

---

## Threading & Actors

- `APGIntentActionClosure` is `@MainActor` and **must** update UI on the main thread.
- `APGIntentAppearanceClosure` is `@Sendable` (not `@MainActor`) and should be **fast** and side-effect free.  
  Return a snapshot of the current state; don’t perform async work here.

---

## Token Conventions

- Use reverse-DNS-like or dotted tokens for hierarchy, e.g.:
  - `"file.new"`, `"file.open"`, `"view.zoomIn"`, `"tools.bulb.toggle"`
- Toolbar item identifiers are `"apgintent-" + token`.

Constants you may use:

```swift
public let kAPGIntentSymbolDefault = "questionmark.square"
public let kAPGIntentSymbolMark = ".fill"                 // appended to symbol when “checked”
public let kAPGIntentKeyPrefix = "apgintent-"             // toolbar item identifier prefix
```

---

## FAQ

**Q: How do I force UI to re-validate after state changes?**  
A: Menus revalidate automatically on open. For toolbars/buttons, call standard Cocoa invalidation (e.g., `window.toolbar?.validateVisibleItems()`), or trigger a UI refresh where appropriate. `APGIntentMacButton` offers `intentValidateUI()` to pull fresh titles.

**Q: Can I pass structured parameters?**  
A: The API accepts a `String`. You can encode small JSON blobs or delimited strings if needed, then parse inside your action/appearance.

**Q: What if I need async state for appearance?**  
A: Keep `appearance` fast/synchronous. For async checks, cache the result in your model and make `appearance` read the cache.

**Q: What is the difference between window and app scope actions?**  
A: Window scope actions are tied to a specific document or window, and override app scope actions with the same token. App scope actions apply everywhere unless shadowed.

**Q: Does APGIntentKit support SwiftUI or iOS?**  
A: Currently the adapters are macOS AppKit-based. SwiftUI and UIKit support are on the roadmap.

---

### Sample Code

The APGExample can be found at [Repository](https://github.com/magesteve/APGExample).

---

## License

[MIT License](LICENSE)

