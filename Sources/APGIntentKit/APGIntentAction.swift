//
//  APGIntentAction.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 2025-07-05
//
//  Defines a functional behavior for a given intent token,
//  including its execution and enablement logic.
//

import Foundation

// MARK: - Struct

/// A structure that defines an action handler for a specific intent.
@MainActor
public struct APGIntentAction: Sendable {

    // MARK: - Properties

    /// Unique token string that must match an `APGIntentInfo.token`.
    public let token: APGIntentToken

    /// Closure executed when the intent is triggered.
    public let actionBlock: APGIntentActionClosure

    /// Optional closure used to determine if the intent is currently enabled/checked/title override.
    public let appearanceBlock: APGIntentAppearanceClosure?

    // MARK: - Initializer

    public init(token: APGIntentToken,
                action: @escaping APGIntentActionClosure,
                appearance: APGIntentAppearanceClosure?) {
        self.token = token
        self.actionBlock = action
        self.appearanceBlock = appearance
    }
}

// MARK: - Class

/// Manages a list of intent actions.
@MainActor
public final class APGIntentActionList {

    // MARK: - Static

    public static let sharedApp = APGIntentActionList()

    // MARK: - Storage

    private var actionDictionary: [APGIntentToken: APGIntentAction] = [:]

    // MARK: - Registration

    private func add(_ action: APGIntentAction) {
        actionDictionary[action.token] = action
    }

    /// Add create and add new action
    public func addAction(token: APGIntentToken,
                          action: @escaping APGIntentActionClosure,
                          appearance: @escaping APGIntentAppearanceClosure) {
        add(APGIntentAction(token: token, action: action, appearance: appearance))
    }

    /// Add create and add new action (no appearance)
    public func addAction(token: APGIntentToken,
                          action: @escaping APGIntentActionClosure) {
        add(APGIntentAction(token: token, action: action, appearance: nil))
    }

    // MARK: - Query

    /// Retrieve all registered actions (sorted lexically by token).
    public var allActions: [APGIntentAction] {
        actionDictionary.values.sorted { $0.token < $1.token }
    }

    /// Returns the current appearance for a token.
    /// - Returns: (enabled, isChecked?, overriddenTitle?).
    ///   If action is not registered, returns (false, nil, nil).
    ///   If action exists but has no appearance block, returns (true, nil, nil).
    public func appearance(token: APGIntentToken) -> (Bool, Bool?, String?) {
        guard let action = actionDictionary[token] else { return (false, nil, nil) }
        guard let block = action.appearanceBlock else { return (true,  nil, nil) }
        return block()
    }

    /// Find action with token
    public func find(token: APGIntentToken) -> APGIntentAction? {
        actionDictionary[token]
    }

    // MARK: - Execution

    /// Perform the action associated with the given token.
    /// - Returns: true if an action was found and executed.
    @discardableResult
    public func perform(token: APGIntentToken) async -> Bool {
        guard let action = actionDictionary[token] else { return false }
        await MainActor.run {
            action.actionBlock()
        }
        return true
    }

    /// Check whether an action exists for the given token.
    public func contains(token: APGIntentToken) -> Bool {
        actionDictionary[token] != nil
    }

    // MARK: - Removal

    /// Remove a specific action.
    public func remove(token: APGIntentToken) {
        actionDictionary.removeValue(forKey: token)
    }

    /// Remove all actions.
    public func removeAll() {
        actionDictionary.removeAll()
    }
}
