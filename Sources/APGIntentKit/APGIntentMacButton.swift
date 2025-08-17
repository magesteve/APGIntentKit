//
//  APGIntentMacButton.swift
//  APGIntentKit
//
//  Created by Steve Sheets on 8/15/25.
//
//  Subclass of NSButton that uses Intents

#if os(macOS)
import Cocoa

// MARK: - Class

/// Subclass of NSButton that uses Intents
@MainActor
public class APGIntentMacButton: NSButton, @preconcurrency APGIntentMacUIProtocol {

    /// Custom identifier string for tracking or lookup (editable in IB)
    public var token: APGIntentToken = String() {
        didSet { updateFromToken() }
    }

    /// Default title captured from intent
    var defaultTitle = String()

    // MARK: - Inits

    /// Programmatic init
    init(token: APGIntentToken) {
        self.token = token
        super.init(frame: .zero)
        commonSetup()
        updateFromToken()
    }

    /// NIB/Storyboard init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    // MARK: - Lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()
        // At this point IB has applied @IBInspectable values.
        Task { @MainActor in
            self.updateFromToken()
        }
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        // Render nicely in IB canvas
        Task { @MainActor in
            self.updateFromToken()
        }
    }

    // MARK: - Setup

    private func commonSetup() {
        bezelStyle = .rounded
        setButtonType(.momentaryPushIn)
        target = self
        action = #selector(handlePress(_:))
    }

    /// Refresh title/defaults from the current token
    private func updateFromToken() {
        guard !token.isEmpty, let info = APGIntentInfoList.shared.find(token: token) else { return }
        title = info.name
        defaultTitle = info.name
    }
    
    // MARK: - Requirement
    
    public func intentValidateUI() {
        Task { @MainActor in
            self.updateFromToken()
        }
    }

    // MARK: - Action

    /// Fire the intent associated with this button's token
    @objc private func handlePress(_ sender: Any?) {
        guard let window = self.window,
              let action = APGIntentMacWindowHelper.findWindowActionInfo(window: window, token: token)
        else { return }

        action.actionBlock()
    }

    // (Optional) Persist token if you archive this view yourself
    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(token, forKey: kAPGIntentCoderToken)
    }
}

#endif
