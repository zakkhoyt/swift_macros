import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct HatchConcurrencyMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddAsyncMacro.self,
    ]
}


enum AsyncError: Error, CustomStringConvertible {
    
    case onlyFunction
    
    var description: String {
        switch self {
        case .onlyFunction:
            return "@AddAsync can be attached only to functions."
        }
    }
}

public struct AddAsyncMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        //       guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
        //          // TODO: Throw error
        //           return []
        //       }
        //
        //       return []
        
        // Inside expansion method.
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AsyncError.onlyFunction // <- Error thrown here
        }
        
        let signature = functionDecl.signature.as(FunctionSignatureSyntax.self)
        let parameters = signature?.parameterClause.parameters
        let firstParameter = parameters?.first
        let parameterName = firstParameter?.firstName // -> arg1
        
        if let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) {
            let parameters = signature.parameterClause.parameters
            
            // 1.
            if let completion = parameters.last,
               let completionType = completion.type.as(FunctionTypeSyntax.self)?.parameters.first,
               let remainPara = FunctionParameterListSyntax(parameters.removingLast()) {
                
                // 2. returns "arg1: String"
                let functionArgs = remainPara.map { parameter -> String in
                    guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else { return "" }
                    return "\(parameter.firstName): \(paraType)"
                }.joined(separator: ", ")
                
                // 3. returns "arg1: arg1"
                let calledArgs = remainPara.map { "\($0.firstName): \($0.firstName)" }.joined(separator: ", ")
                
                // 4.
                return [
                    """
                    func \(functionDecl.name)(\(raw: functionArgs)) async -> \(completionType) {
                        await withCheckedContinuation { continuation in
                            self.\(functionDecl.name)(\(raw: calledArgs)) { object in
                                continuation.resume(returning: object)
                            }
                        }
                    }
                    """
                ]
            }
        }
        return []
    }
}