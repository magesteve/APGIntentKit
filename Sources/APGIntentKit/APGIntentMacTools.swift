//
//  APGIntentMacTools.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 8/15/25.
//
//  Utilities for MacOS App using Intents
//

#if os(macOS)

import Cocoa

// MARK: - Class

/// Static class with utilities for MacOS App using Intents
@MainActor
public class APGIntentMacTools {
    
// MARK: - Menu Related Functions
    
    /// Add a new menu before the standard Help menu.
    /// - Parameters:
    ///   - name: The title for the new menu (e.g. 'Tools').
    ///   - tokens: An array of tokens to appear inside it.
    public static func addMenuBeforeHelp(named name: String, tokens: [APGIntentToken]) {
        guard let mainMenu = NSApp.mainMenu else { return }

        // Build the submenu
        let submenu = NSMenu(title: name)
        for token in tokens {
            submenu.addItem(APGIntentMenuItem(token: token))
        }

        // Top-level item containing that submenu
        let menuItem = NSMenuItem(title: name, action: nil, keyEquivalent: "")
        menuItem.submenu = submenu

        // Find the Help menu via NSApp.helpMenu (already localized)
        if let helpMenu = NSApp.helpMenu,
           let helpContainerIndex = mainMenu.items.firstIndex(where: { $0.submenu === helpMenu }) {
            mainMenu.insertItem(menuItem, at: helpContainerIndex)  // insert just before Help
        } else {
            // No Help menu present; append at the end
            mainMenu.addItem(menuItem)
        }
    }
    
    /// Add Apple Menu Items
    public static func addAppMenuIntents(about aboutTokens: [APGIntentToken] = [],
                                         settings settingsTokens: [APGIntentToken] = []) {
        guard !(aboutTokens.isEmpty && settingsTokens.isEmpty) else { return }

        guard let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String else { return }
        
        guard let appSubmenu = APGIntentMacTools.findNamedMenu(appName) else { return }

        if !settingsTokens.isEmpty {
            replaceItem(menu: appSubmenu, at: 2, with: settingsTokens)
        }

        if !aboutTokens.isEmpty {
            replaceItem(menu: appSubmenu, at: 0, with: aboutTokens)
        }
    }
    
    /// Add Help Menu Items
    public static func addHelpMenuIntents(help helpTokens: [APGIntentToken]) {
        guard !helpTokens.isEmpty else { return }

        guard let helpSubmenu = NSApp.helpMenu else { return }

        for token in helpTokens {
            let newItem = APGIntentMenuItem(token: token)
            helpSubmenu.addItem(newItem)
        }
    }
    
    static func replaceItem(menu: NSMenu, at index: Int, with newTokens: [APGIntentToken]) {
        guard index >= 0 && index < menu.items.count else { return }
        
        // Remove the old item
        menu.removeItem(at: index)
        
        // Insert new items at that index in order
        for (offset, token) in newTokens.enumerated() {
            if token.isEmpty {
                menu.insertItem(NSMenuItem.separator(), at: index + offset)
            }
            else {
                let item = APGIntentMenuItem(token: token)
                menu.insertItem(item, at: index + offset)
            }
        }
    }

    /// Given name, find menu in main menu
    static func findNamedMenu(_ named: String) -> NSMenu? {
        guard let mainMenu = NSApp.mainMenu else { return nil }
        
        let menuIndex = mainMenu.indexOfItem(withTitle: named)
        
        guard menuIndex >= 0,
              let menuItem = mainMenu.item(at: menuIndex),
              let submenu = menuItem.submenu else { return nil }

        return submenu
    }

    /// If menu has items, add sperator (usually follow by more menus).
    func addSeparatorIfNeeded(_ menu: NSMenu) {
        if !menu.items.isEmpty {
            menu.addItem(NSMenuItem.separator())
        }
    }

}

#endif

