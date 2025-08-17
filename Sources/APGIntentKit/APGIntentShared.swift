//
//  APGIntentShared.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 8/17/25.
//
//  Shared constants, types & protocols for Intent
//

// MARK: - Contants

/// Default Symbol
public let kAPGIntentSymbolDefault = "questionmark.square"

/// Suffix to make symbol marked
public let kAPGIntentSymbolMark = ".fill"

/// Key to use for encoding/decoding a token field
public let kAPGIntentCoderToken = "token"

/// Prefix for Toolbar identifiers
public let kAPGIntentKeyPrefix = "apgintent-"

// MARK: - Typealias

/// Type of token (String currently)
public typealias APGIntentToken = String

/// Simple closure with no results or paramts
public typealias APGIntentActionClosure = @Sendable @MainActor () -> Void

/// Returns: (enabled, isChecked?, overriddenTitle?)
public typealias APGIntentAppearanceClosure = @Sendable () -> (Bool, Bool?, String?)

// MARK: - Protocol

/// Protocol for MacOS UI elements (ex: Button)
public protocol APGIntentMacUIProtocol {
    
    /// Token
    var token: APGIntentToken { get set }
    
    /// Validate UI
    func intentValidateUI()
}

#if os(macOS)

// MARK: - MacOS Only Protocol

/// Protocol for window to have them support Intent menu & toolbar.
@MainActor
public protocol APGIntentMacWindowProtocol {
    
    /// Helper to store information for intents
    var intentHelper: APGIntentMacWindowHelper { get }
    
}

#endif



