// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(
    module: "ZakkroMacros",
    type: "StringifyMacro"
)


@freestanding(expression)
public macro logify<T>(
    _ value: T
) -> String = #externalMacro(
    module: "ZakkroMacros",
    type: "LogifyMacro"
)

@freestanding(declaration, names: named(l))
public macro dlogify<T>(
    _ value: T
) = #externalMacro(
    module: "ZakkroMacros",
    type: "DLogifyMacro"
)



/// Defines a subset of the 'Slope enum
///
/// Generates an initializer that converts a 'Slope' to this type if the slope is
/// declared in this subset, otherwise returns 'nil'
///
/// - Important: All enum cases declared in this macro must also exist in the Slope enum.
@attached(member, names: named(init))
public macro SlopeSubset() = #externalMacro(
    module: "ZakkroMacros",
    type: "SlopeSubsetMacro"
)


/// A macro that produces an unwrapped URL in case of a valid input URL.
/// For example,
///
///     #URL("https://www.avanderlee.com")
///
/// produces an unwrapped `URL` if the URL is valid. Otherwise, it emits a compile-time error.
///
/// **SeeAlso:**
///
/// [Article](https://www.avanderlee.com/swift/macros/)
///
@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(
    module: "ZakkroMacros",
    type: "URLMacro"
)


@attached(peer, names: overloaded)
public macro AddAsync() = #externalMacro(
    module: "ZakkroMacros",
    type: "AddAsyncMacro"
)



////@freestanding(expression)
////public ma ro dictionaryStorage<T>(_ value: T) -> (T, String) = #externalMacro(module: "ZakkroMacros", type: "DictionaryStorageMacro")
//
///// Adds accessors to get and set the value of the specified property in a dictionary
///// property called `storage`.
//@attached(accessor)
//public macro DictionaryStorage(key: String? = nil) = #externalMacro(module: "ZakkroMacros", type: "DictionaryStorageMacro")
//
//



/// A macro that generates a logger function to let the
/// object log the issue within but only during debuging. For example,
///
///     @DebugLogger
///     class Foo {}
///
/// `produces a function`
///     func log(issue: String) {
///         #if DEBUG
///         print("In Foo - \(issue)")
///         #endif
///     }
/// **SeeAlso:**
///
/// [Article](https://betterprogramming.pub/swift-macros-4f32e33ccf19)
///
@attached(member, names: named(log(issue:)))
public macro DebugLogger() = #externalMacro(
    module: "ZakkroMacros",
    type: "DebugLoggerMacro"
)
