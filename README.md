# APGIntentKit

A lightweight Swift package for **standardizing UI commands** (menu items, toolbar items, buttons) around a simple **Intent** model.  
It separates **what the UI shows** (name, hint, icon, shortcut) from **what it does** (closure to invoke, enable/disable, checkmark, and dynamic title), so you can declare commands once and reuse them across UI surfaces.

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
- [Roadmap](#roadmap)
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
.package(url: "https://github.com/your-org/APGIntentKit.git", from: "0.2.0")
```

Then add `"APGIntentKit"` to your target dependencies.

**Minimum**: macOS 11+ (SF Symbols in toolbar items require 11+).  
The macOS adapters are wrapped in `#if os(macOS)`.

---

## Concepts

### APGIntentToken

A `typealias` for `String`. It uniquely identifies a command/intent.

```swift
public typealias APGIntentToken = String
```

### APGIntentInfo

UI metadata the user sees:

```swift
public struct APGIntentInfo: Hashable, Sendable {
    public let token: APGIntentToken
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

### APGIntentAction

Behavior and appearance:

```swift
public typealias APGIntentActionClosure = @Sendable @MainActor () -> Void
public typealias APGIntentAppearanceClosure = @Sendable () -> (Bool, Bool?, String?)
```

---

## Quick Start

1. **Register Info**

```swift
APGIntentInfoList.shared.add(contentsOf: [
    APGIntentInfo(token: "about", 
        name: "About My App", 
        symbolName: "questionmark.circle"),
    APGIntentInfo(token: "faq", 
        name: "FAQ", 
        symbolName: "book"),
    APGIntentInfo(token: "bulb", 
        name: "Bulb", 
        symbolName: "lightbulb", 
        menuKey: "1")
])
```

2. **Register App level Actions**

```swift
APGIntentActionList.sharedApp.addAction(token: "about") {
    // Display custom About Window
}
APGIntentActionList.sharedApp.addAction(token: "faq") {
    // Display custom FAQ Window
}
```

3. **Register Window/Document/View levelActions**

Using helper functions from view controller (assume field fBulbflag).


```swift
guard let helper = findIntentHelper(for: self) else { return }
helper.addWindowAction(token: "bulb",
                      action: { fBulbflag = !fBulbflag },
                  appearance: { return (true, fBulbflag, nil) }
)
```

4. **Use in Menus**

Using helper functions to add to App, Help or new menus.

```swift
APGIntentMacTools.addAppMenuIntents(about: ["about", "faq"])
APGIntentMacTools.addMenuBeforeHelp(named: "Tools", tokens: ["bulb"])
```

5. **Use in Toolbars**

Using helper functions to add a Toolbar to a Window from it's view controller.

```swift
guard let helper = findIntentHelper(for: self) else { return }
helper.addIntentToolbar(unique: "mywindow",
                      defaults: ["bulb"],
                        extras: ["about", "faq"])
```

6. **Use in Buttons**

Use APGIntentButton class with single token parameter.

```swift
let aboutButton = APGIntentButton(token: "about")
```

---

## Roadmap

- Invalidation center for broadcasting UI refreshes
- Async appearance support
- SwiftUI adapters
- UIKit support


