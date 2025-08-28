// The Swift Programming Language
// https://docs.swift.org/swift-book

// MARK: - Struct

/// Abstract Struct for Package Information
public struct APGIntent {
    
    // MARK: - Static Constants
    
    /// Version information of package
    public static let version = "0.5.0"
    
    // Intent ident Constants
    
    /// Show About Window Intent
    public static let about = "APG-about"
    
    /// Show Export Window Intent
    public static let export = "APG-export"
    
    /// Show FAQ Window Intent
    public static let faq = "APG-faq"
    
    /// Show Get Started Window Intent
    public static let features = "APG-getstarted"
    
    /// Show Inpot Window Intent
    public static let inport = "APG-inport"
    
    /// Show New Doc Window Intent
    public static let newDoc = "APG-NewDOc"
    
    /// Show OpenDoc Window Intent
    public static let opendoc = "APG-opendoc"
    
    /// Show Settings Window Intent
    public static let settings = "APG-settings"
    
    /// Show Welcome Window Intent
    public static let welcome = "APG-welcome"
    
    /// Show What's New Window Intent
    public static let whatsnew = "APG-whatsnew"
    
    // Symbol constants
    
    /// Default Symbol
    public static let symbolDefault = "questionmark.square"

    /// Suffix to make symbol marked
    public static let symbolMark = ".fill"

    /// Key to use for encoding/decoding a token field
    public static let coderToken = "token"

    /// Prefix for Toolbar identifiers
    public static let keyPrefix = "apgintent-"

}
