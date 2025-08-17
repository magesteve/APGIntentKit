//
//  APGIntentMacMenuItem.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 2025-07-05
//
//  A menu item that represents a specific intent by identifier,
//  manages its own enabled state, and performs the associated action.
//

#if os(macOS)

import Cocoa

// MARK: - Class

/// A menu item linked to an intent by identifier, enabling and performing itself.
@MainActor
public final class APGIntentMenuItem: NSMenuItem {

    // MARK: - Stored Properties

    /// The unique token of the intent this menu item represents.
    public var token: APGIntentToken
    
    /// Always on? No special validation
    public var alwaysOn: Bool

    // MARK: - Initializer

    /// Create a new menu item for a given intent token.
    /// - Parameter token: The token of the intent to link.
    public init(token: APGIntentToken) {
        self.token = token

        let intentInfo = APGIntentInfoList.shared.find(token: token)
        
        let name = intentInfo?.name ?? token
        let key = intentInfo?.menuKey ?? String()
        self.alwaysOn = intentInfo?.alwaysOn ?? true
        
        super.init(title: name, action: #selector(performIntent(_:)), keyEquivalent: key)
        if intentInfo?.menuKey != nil {
            self.keyEquivalentModifierMask = [.command]
        }
        self.target = self
    }

    /// Required for NSCoding (not used directly).
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action Handler

    /// Perform the associated intent's action using the topmost document (if any).
    @objc private func performIntent(_ sender: Any?) {
        guard let action = APGIntentMacWindowHelper.findTopmostActionInfo(token: token) else { return }

        action.actionBlock()
    }


}

// MARK: - Validation

extension APGIntentMenuItem: NSMenuItemValidation {
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if alwaysOn {
            return true
        }

        guard let action = APGIntentMacWindowHelper.findTopmostActionInfo(token: token) else { return false }
        
        guard let block = action.appearanceBlock else { return true }

        let (isEnabled, isMarked, title) = block()
        
        if let title {
            menuItem.title = title
        }
        
        if let isMarked {
            menuItem.state = isMarked ? .on : .off
        }
        
        return isEnabled
    }
}

#endif
