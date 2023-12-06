// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "ZakkroMacros", type: "StringifyMacro")


/// Defines a subset of the 'Slope enum
///
/// Generates an initializer that converts a 'Slope' to this type if the slope is
/// declared in this subset, otherwise returns 'nil'
///
/// - Important: All enum cases declared in this macro must also exist in the Slope enum.
@attached(member, names: named(init))
public macro SlopeSubset() = #externalMacro(module: "ZakkroMacros", type: "SlopeSubsetMacro")


////@freestanding(expression)
////public ma ro dictionaryStorage<T>(_ value: T) -> (T, String) = #externalMacro(module: "ZakkroMacros", type: "DictionaryStorageMacro")
//
///// Adds accessors to get and set the value of the specified property in a dictionary
///// property called `storage`.
//@attached(accessor)
//public macro DictionaryStorage(key: String? = nil) = #externalMacro(module: "ZakkroMacros", type: "DictionaryStorageMacro")
//
//

