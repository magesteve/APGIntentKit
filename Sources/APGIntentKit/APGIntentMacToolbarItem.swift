//
//  APGIntentMacToolbarItem.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 2025-07-05
//
//  A toolbar item that represents a specific intent by identifier,
//  enabling and performing itself.
//

#if os(macOS)

import Cocoa

// MARK: - Class

/// A toolbar item linked to an intent by identifier, enabling and performing itself.
@MainActor
public final class APGIntentToolbarItem: NSToolbarItem {

    // MARK: - Stored Properties

    /// The unique token of the intent this toolbar item represents.
    public let token: String
    
    /// Optional param data for action.
    public var param: String = ""

    /// Always on?
    public private(set) var alwaysOn: Bool = false

    /// Helper
    public weak var helper: APGIntentMacWindowHelper?

    /// Currently marked?
    public var currentlyMarked = false

    // Cached metadata from APGIntentInfo (avoids async/actor calls during validate)
    private var defaultShortName: String
    private var defaultLongName: String
    private var defaultDescription: String
    private var baseSymbolName: String?
    private var baseHint: String?

    // MARK: - Initializer

    /// Create a new toolbar item for a given intent token.
    /// - Parameters:
    ///   - token: The token of the intent to link.
    ///   - helper: Window helper to resolve window-scoped actions/appearance.
    public init(token: String, helper: APGIntentMacWindowHelper?) {
        self.token = token
        self.helper = helper

        // Seed with safe defaults synchronously (no actor calls here)
        self.defaultShortName = token
        self.defaultLongName = token
        self.defaultDescription = token
        self.baseSymbolName = kAPGIntentSymbolDefault
        self.baseHint = token

        let itemIdentifier = NSToolbarItem.Identifier(kAPGIntentKeyPrefix + token)
        super.init(itemIdentifier: itemIdentifier)

        // Apply initial UI using defaults
        self.label = defaultShortName
        self.paletteLabel = defaultLongName
        self.toolTip = defaultDescription
        self.image = makeSymbolImage()
        self.target = self
        self.action = #selector(performIntent(_:))

        // Now fetch real info asynchronously from the actor and update UI/cache
        Task { [weak self] in
            guard let self else { return }
            // Safe: crossing into actor boundary asynchronously
            let info = APGIntentInfoList.shared.find(token: token)

            // Apply on main actor (we already are, but be explicit if this code moves)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.apply(info: info)
            }
        }
    }

    // MARK: - Symbol

    /// Build an NSImage for the current mark state using cached symbol info.
    private func makeSymbolImage() -> NSImage? {
        let symbolBase = baseSymbolName ?? kAPGIntentSymbolDefault
        let name = currentlyMarked ? (symbolBase + kAPGIntentSymbolMark) : symbolBase
        return NSImage(systemSymbolName: name, accessibilityDescription: baseHint ?? defaultDescription)
    }

    // MARK: - Actor data application

    /// Update cached fields and visible UI from APGIntentInfo snapshot.
    private func apply(info: APGIntentInfo?) {
        self.alwaysOn = info?.alwaysOn ?? self.alwaysOn
        self.defaultShortName = info?.useShortName ?? self.defaultShortName
        self.defaultLongName = info?.useLongName ?? self.defaultLongName
        self.defaultDescription = info?.description ?? self.defaultDescription
        self.baseSymbolName = info?.symbolName ?? self.baseSymbolName
        self.baseHint = info?.hint ?? self.baseHint

        // Reflect in UI now
        self.label = self.defaultShortName
        self.paletteLabel = self.defaultLongName
        self.toolTip = self.defaultDescription
        self.image = makeSymbolImage()
    }

    // MARK: - Action Handler

    /// Perform the associated intent's action using the topmost document (if any).
    @objc private func performIntent(_ sender: Any?) {
        guard let window = self.helper?.window else { return }
        guard let action = APGIntentMacWindowHelper.findWindowActionInfo(window: window, token: token) else { return }
        action.actionBlock(param)
    }

    // MARK: - Validation

    /// Automatically called by Cocoa to determine if the toolbar item should be enabled.
    public override func validate() {
        if alwaysOn {
            self.isEnabled = true
            return
        }

        guard
            let window = self.helper?.window,
            let action = APGIntentMacWindowHelper.findWindowActionInfo(window: window, token: token)
        else {
            self.isEnabled = false
            // revert to defaults when no action is present
            if self.label != defaultShortName { self.label = defaultShortName }
            if self.image == nil { self.image = makeSymbolImage() }
            return
        }

        if let block = action.appearanceBlock {
            let (enabled, marked, text) = block(param)

            // Update check/mark state and symbol if changed
            if let marked, marked != currentlyMarked {
                currentlyMarked = marked
                self.image = makeSymbolImage()
            }

            // Update label override (or restore default if nil/empty)
            if let t = text, !t.isEmpty {
                if self.label != t { self.label = t }
            } else if self.label != defaultShortName {
                self.label = defaultShortName
            }

            self.isEnabled = enabled
        } else {
            // No appearance block => enabled by default, default label/symbol
            self.isEnabled = true
            if self.label != defaultShortName { self.label = defaultShortName }
            self.image = makeSymbolImage()
        }
    }
}

#endif
