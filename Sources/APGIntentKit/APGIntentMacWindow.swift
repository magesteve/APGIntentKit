//
//  APGIntentMacWindow.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 8/16/25.
//
//  Tools to add functionality to Mac Window to support
//  Menu actions and Toolbar Items.
//

#if canImport(AppKit)

import Foundation
import AppKit

// MARK: - Class

/// Subclass of that supports APGIntentMacWindowProtocol, and has a intentHelper field.
@MainActor
public class APGIntentMacWindowController: NSWindowController, APGIntentMacWindowProtocol {
    
    // Protocol requirement
    public let intentHelper: APGIntentMacWindowHelper = APGIntentMacWindowHelper()
}

/// Mac Window Helper for Intents
@MainActor
public class APGIntentMacWindowHelper: NSObject, NSToolbarDelegate {
    
    // MARK: - Variables
    
    /// Weak reference to WIndow
    public weak var window: NSWindow?
    
    /// Unique Idenfitier
    public var toolbarUnique: NSToolbar.Identifier = String()
    
    // Default Identier
    public var listDefaults: [NSToolbarItem.Identifier] = []

    // Allowed Identier
    public var listAllowed: [NSToolbarItem.Identifier] = []

    /// Global shared application-level Action list.
    private var windowListActionInfo = APGIntentActionList()
    
    // MARK: - Static Function
    
    /// Returns the NSWindowController of the topmost (front) window, if any.
    public static func findTopmostHelper() -> APGIntentMacWindowHelper? {
        for window in NSApp.orderedWindows {
            if window.isVisible, let controller = window.windowController {
                if let prot = controller as? APGIntentMacWindowProtocol {
                    return prot.intentHelper
                }
            }
        }
        
        return nil
    }
    /// Find Action for token (checking window and app level list)
    public static func findTopmostActionInfo(token: String) -> APGIntentAction? {
        if let helper = findTopmostHelper() {
            if let action = helper.windowListActionInfo.find(token: token) {
                return action
            }
        }
        
        return APGIntentActionList.sharedApp.find(token: token)
    }
    
    /// FInd action for given window
    public static func findWindowActionInfo(window: NSWindow?, token: String) -> APGIntentAction? {
        if let window, window.isVisible, let controller = window.windowController {
            if let prot = controller as? APGIntentMacWindowProtocol {
                if let action = prot.intentHelper.windowListActionInfo.find(token: token) {
                    return action
                }
            }
        }

        return APGIntentActionList.sharedApp.find(token: token)
    }
    
    /// Add create and add new action to window
    public func addWindowAction(token: String,
                          action: @escaping APGIntentActionClosure,
                          appearance: @escaping APGIntentAppearanceClosure) {
        windowListActionInfo.addAction(token: token, action: action, appearance: appearance)
    }

    /// Add create and add new action to window (no appearance)
    public func addWindowAction(token: String,
                          action: @escaping APGIntentActionClosure) {
        windowListActionInfo.addAction(token: token, action: action)
    }
    
    // MARK: - Functions
    
    /// Attaches a simple toolbar (Undo, Quit) to `window` if present.
    public func addIntentToolbar(unique: String,
                                 defaults: [String],
                                 extras: [String] = []) {
        guard let win = window, win.toolbar == nil, !unique.isEmpty else { return }
        
        listDefaults = []
        listAllowed = []
        listDefaults.append(.flexibleSpace)
        for item in defaults {
            let s = NSToolbarItem.Identifier(APGIntent.keyPrefix+item)
            self.listDefaults.append(s)
            self.listAllowed.append(s)
        }
        for item in extras {
            let s = NSToolbarItem.Identifier(APGIntent.keyPrefix+item)
            self.listAllowed.append(s)
        }
        listAllowed.append(.flexibleSpace)

        self.toolbarUnique = NSToolbar.Identifier(APGIntent.keyPrefix+unique)
        
        let tb = NSToolbar(identifier: toolbarUnique)
        tb.allowsUserCustomization = true
        tb.autosavesConfiguration = true
        tb.delegate = self
        win.toolbar = tb
        win.toolbarStyle = .unified
    }

    // MARK: - Toolbar delegate
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return listAllowed
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return listDefaults
    }
    
    public func toolbar(_ toolbar: NSToolbar,
                        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                        willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var token = itemIdentifier.rawValue

        guard token.hasPrefix(APGIntent.keyPrefix) else { return nil }
        
        token = String(token.dropFirst(APGIntent.keyPrefix.count))
        
        let item  = APGIntentToolbarItem(token: token, helper: self)

        return item
    }

}

// MARK: - Extensions

// Extensions to NSViewController
public extension NSViewController {
    
    /// Find helper associated with window
    func findIntentHelper(for viewController:NSViewController) -> APGIntentMacWindowHelper? {
        guard let window = self.view.window, let controller = window.windowController as? APGIntentMacWindowProtocol else { return nil }
        
        controller.intentHelper.window = window
        
        return controller.intentHelper
    }
}

#endif
