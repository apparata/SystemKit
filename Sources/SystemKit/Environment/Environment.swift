//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

/// Gets and sets environment variables for the current process.
public class Environment {
    
    /// Shared instance got use with subscript syntax.
    public static let variables = Environment()
    
    /// Returns a dictionary of all environment variables for
    /// the current process.
    public var all: [String: String] {
        return ProcessInfo.processInfo.environment
    }
    
    /// Class method that gets the value of the specified environment variable.
    ///
    /// - Example:
    /// ```
    /// let name = Environment.variable("NAME")
    /// ```
    ///
    /// - Parameter name: Name of the environment variable to get value for.
    /// - Returns: Returns value of environment variable or nil if the variable
    ///            is not set.
    public static func variable(_ name: String) -> String? {
        return variables[name]
    }
    
    
    /// Class method that sets the value of the specificed environment variable.
    ///
    /// - Example:
    /// ```
    /// Environment.set(variable: "NAME", "VALUE")
    /// Environment.set(variable: "NAME", "VALUE", overwrite: false)
    /// ```
    ///
    /// - Parameters:
    ///   - variable: Name of variable to set.
    ///   - value: Value to set variable to, or nil to unset variable.
    ///   - overwrite: Indicate whether value should be overwritten or not.
    public static func set(variable name: String, value: String?, overwrite: Bool = true) {
        if let value = value {
            setenv(name, value, overwrite ? 1 : 0)
        } else {
            unset(variable: name)
        }
    }
    
    /// Class method that unsets the specified environment variable.
    ///
    /// - Example:
    /// ```
    /// Environment.unset(variable: "NAME")
    /// ```
    ///
    /// - Parameter variable: Name of the environment variable to unset.
    public static func unset(variable name: String) {
        unsetenv(name)
    }

    /// Unsets the specified environment variable.
    ///
    /// - Example:
    /// ```
    /// let env = Environment()
    /// env.unset(variable: "NAME")
    /// ```
    ///
    /// - Parameter variable: Name of the environment variable to unset.
    public func unset(variable: String) {
        unsetenv(variable)
    }
    
    /// Gets or sets an environment variable using subscript syntax.
    ///
    /// - Example:
    /// ```
    /// let name = Environment.variables["NAME"]
    /// Environment.variables["NAME"] = "VALUE"
    /// ```
    ///
    /// - Parameter key: Variable to get or set.
    public subscript(key: String) -> String? {
        get {
            return ProcessInfo.processInfo.environment[key]
        }
        set {
            setenv(key, newValue, 1)
        }
    }
    
}
