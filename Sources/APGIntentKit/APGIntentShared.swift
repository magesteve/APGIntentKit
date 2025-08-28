//
//  APGIntentShared.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 8/17/25.
//
//  Shared constants, types & protocols for Intent
//

// MARK: - Typealias

/// Simple closure with no results or paramts
public typealias APGIntentActionClosure = @Sendable @MainActor (String) -> Void

/// Returns: (enabled, isChecked?, overriddenTitle?)
public typealias APGIntentAppearanceClosure = @Sendable (String) -> (Bool, Bool?, String?)

// MARK: - Protocol

/// Protocol for MacOS UI elements (ex: Button)
public protocol APGIntentMacUIProtocol {
    
    /// Token
    var token: String { get set }
    
    /// Validate UI
    func intentValidateUI()
}

#if canImport(AppKit)

// MARK: - MacOS Only Protocol

/// Protocol for window to have them support Intent menu & toolbar.
@MainActor
public protocol APGIntentMacWindowProtocol {
    
    /// Helper to store information for intents
    var intentHelper: APGIntentMacWindowHelper { get }
    
}

#endif



