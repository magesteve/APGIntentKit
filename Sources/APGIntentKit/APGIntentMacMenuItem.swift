//
//  APGIntentMacMenuItem.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 2025-07-05
//
//  A menu item that represents a specific intent by identifier,
//  manages its own enabled state, and performs the associated action.
//

#if canImport(AppKit)

import Foundation
import AppKit

// MARK: - Class

/// A menu item linked to an intent by identifier, enabling and performing itself.
@MainActor
public final class APGIntentMenuItem: NSMenuItem {

    // MARK: - Stored Properties

    /// The unique token of the intent this menu item represents.
    public var token: String
    
    /// Optional param data for action.
    public var param: String = String()
    
    /// Always on? No special validation
    public var alwaysOn: Bool

    // MARK: - Initializer

    /// Create a new menu item for a given intent token.
    /// - Parameters:
    ///   - token: The token of the intent to link.
    ///   - param: Optional param data for action.
    public init(token: String,
                param: String = String()) {
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
        fatalError(String())
    }

    // MARK: - Action Handler

    /// Perform the associated intent's action using the topmost document (if any).
    @objc private func performIntent(_ sender: Any?) {
        APGIntent.perform(token: token, param: param)
    }

}

// MARK: - Validation

extension APGIntentMenuItem: NSMenuItemValidation {
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.isSeparatorItem {
            return false
        }

        if alwaysOn {
            return true
        }

        guard let action = APGIntentMacWindowHelper.findTopmostActionInfo(token: token) else { return false }
        
        guard let block = action.appearanceBlock else { return true }

        let (isEnabled, isMarked, title) = block(param)
        
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
