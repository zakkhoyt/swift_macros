import Foundation

@attached(peer, names: overloaded)
public macro AddAsync(
) = #externalMacro(
    module: "HatchConcurrencyMacroImplementation",
    type: "AddAsyncMacro"
)