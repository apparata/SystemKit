//
//  Copyright © 2018 Apparata AB. All rights reserved.
//

import Foundation

/// Standard POSIX environment variable names commonly available across Unix-like systems.
///
/// This enumeration provides type-safe access to well-known environment variables
/// that are typically present in macOS, iOS, and other POSIX-compliant systems.
///
/// ## Usage
///
/// ```swift
/// let homePath = Environment[StandardEnvironmentVariables.home.rawValue]
/// let currentUser = Environment[StandardEnvironmentVariables.user.rawValue]
/// ```
///
/// ## Topics
///
/// ### User Information
/// - ``user``
///
/// ### Path Variables
/// - ``home``
/// - ``path``
/// - ``tmpDir``
///
/// ### Shell Variables
/// - ``shell``
///
/// ### Terminal Variables
/// - ``term``
/// - ``termProgram``
///
/// ### Locale Variables
/// - ``tz``
/// - ``lang``
/// - ``language``
/// - ``lcCType``
/// - ``lcNumeric``
/// - ``lcTime``
/// - ``lcCollate``
/// - ``lcMonetary``
/// - ``lcMessages``
/// - ``lcPaper``
/// - ``lcName``
/// - ``lcAddress``
/// - ``lcTelephone``
/// - ``lcMeasurement``
/// - ``lcIdentification``
/// - ``lcAll``
public enum StandardEnvironmentVariables: String {

    // MARK: - User

    /// The login name of the current user.
    case user = "USER"

    // MARK: - Paths

    /// The path to the current user's home directory.
    case home = "HOME"

    /// A colon-separated list of directories where executable programs are located.
    case path = "PATH"

    /// The path to the directory for temporary files.
    case tmpDir = "TMPDIR"

    // MARK: - Shell

    /// The path to the user's preferred command-line shell.
    case shell = "SHELL"

    // MARK: - Terminal

    /// The type of terminal being used.
    case term = "TERM"

    /// The name of the terminal program (e.g., "Apple_Terminal", "iTerm.app").
    case termProgram = "TERM_PROGRAM"

    // MARK: - Locale

    /// The time zone identifier.
    case tz = "TZ"

    /// The primary language and locale setting.
    case lang = "LANG"

    /// A colon-separated list of languages in preference order.
    case language = "LANGUAGE"

    /// Locale setting for character classification and case conversion.
    case lcCType = "LC_CTYPE"

    /// Locale setting for numeric formatting.
    case lcNumeric = "LC_NUMERIC"

    /// Locale setting for time and date formatting.
    case lcTime = "LC_TIME"

    /// Locale setting for collation (sorting) order.
    case lcCollate = "LC_COLLATE"

    /// Locale setting for monetary value formatting.
    case lcMonetary = "LC_MONETARY"

    /// Locale setting for message translations.
    case lcMessages = "LC_MESSAGES"

    /// Locale setting for paper size.
    case lcPaper = "LC_PAPER"

    /// Locale setting for personal name formatting.
    case lcName = "LC_NAME"

    /// Locale setting for address formatting.
    case lcAddress = "LC_ADDRESS"

    /// Locale setting for telephone number formatting.
    case lcTelephone = "LC_TELEPHONE"

    /// Locale setting for measurement units.
    case lcMeasurement = "LC_MEASUREMENT"

    /// Locale setting for identification information.
    case lcIdentification = "LC_IDENTIFICATION"

    /// Overrides all other locale settings.
    case lcAll = "LC_ALL"
}

