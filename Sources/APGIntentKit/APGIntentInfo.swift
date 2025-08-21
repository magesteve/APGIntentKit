//
//  APGIntentInfo.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 2025-07-05
//
//  A structure that defines a uniquely intent token,
//  including its human-readable name, unique identifier, icon name,
//  descriptive text, and optional menu key shortcut.
//

import Foundation

// MARK: - Struct

/// A structure that describes a unique info or action within the system.
public struct APGIntentInfo: Hashable, Sendable {
    
    // MARK: - Properties

    /// Globally unique  token for the info.
    public let token: String
    
    /// Human-readable name of the info.
    public let name: String
    
    /// UI Always on (no validation)
    public let alwaysOn: Bool
    
    /// Short name
    public let shortName: String?

    /// Long name
    public let longName: String?

    /// Description of what the info does.
    public let description: String?

    /// Hint of what the info does.
    public let hint: String?

    /// SF Symbol name
    public let symbolName: String?

    /// Optional key equivalent used for menu item shortcuts.
    public let menuKey: String?

    // MARK: - Computed Var

    /// Calculated short name
    public var useShortName: String {
        if let shortName {
            return shortName
        }
        
        return name
    }

    /// Calculated long name
    public var useLongName: String {
        if let longName {
            return longName
        }
        
        return name
    }

    // MARK: - Initializer

    /// Create a new info record.
    /// - Parameters:
    ///   - token: Globally unique token for this info.
    ///   - name: Human-readable name for the UI.
    ///   - alwaysOn: UI is always on, never invalidated.
    ///   - shortName: Optional shorter version
    ///   - longName: Optional longerer version
    ///   - description: Optional Description of the purpose or function.
    ///   - hint: Optional Hint of the purpose or function.
    ///   - symbolName: Optional Symbol Icon name used in toolbars or menus.
    ///   - menuKey: Optional menu shortcut key (e.g., 'n' for ⌘N).
    public init(token: String,
                name: String,
                alwaysOn: Bool = true,
                shortName: String? = nil,
                longName: String? = nil,
                description: String? = nil,
                hint: String? = nil,
                symbolName: String? = nil,
                menuKey: String? = nil) {
        self.token = token
        self.name = name
        self.alwaysOn = alwaysOn
        self.shortName = shortName
        self.longName = longName
        self.description = description
        self.hint = hint
        self.symbolName = symbolName
        self.menuKey = menuKey
    }
}

// MARK: - Class

/// A class that manages a list of defined info instances.
@MainActor
public final class APGIntentInfoList {
    
    // MARK: - Static Properties

    /// Shared List of Intent Information
    public static let shared = APGIntentInfoList()

    // MARK: - Stored Properties

    /// The list of all registered info objects.
    public private(set) var infoList: [APGIntentInfo] = []

    // MARK: - Initialization

    /// Create an empty info list.
    public init() {}

    // MARK: - API

    /// Add a single info to the list.
    /// - Parameter intent: The info to add.
    public func add(_ intentInfo: APGIntentInfo) {
        infoList.append(intentInfo)
    }

    /// Add multiple infos to the list.
    /// - Parameter intents: An array of infos to append.
    public func add(contentsOf info: [APGIntentInfo]) {
        infoList.append(contentsOf: info)
    }

    /// Look up an info by its unique token.
    /// - Parameter token: The token to search for.
    /// - Returns: The matching `APGIntentInfo`, or nil if not found.
    public func find(token: String) -> APGIntentInfo? {
        infoList.first { $0.token == token }
    }

    /// Check if the list already contains an info with the given token.
    /// - Parameter token: The token to check.
    public func contains(token: String) -> Bool {
        infoList.contains { $0.token == token }
    }
}

