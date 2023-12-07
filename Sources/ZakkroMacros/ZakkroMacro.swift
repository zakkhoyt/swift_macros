import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct ZakkroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        SlopeSubsetMacro.self,
        URLMacro.self,
        AddAsyncMacro.self,
        LogifyMacro.self,
        DebugLoggerMacro.self,
        DLogifyMacro.self
    ]
}


/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        return "(\(argument), \(literal: argument.description))"
    }
}

public struct LogifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
//        let s = "\"test"
        let logline = "logger.debug(\(argument))"
        
        return "\\\"\(raw: logline)\\\""
//        return #"logger.debug("\(\#(argument))")"#
//        return #"logger.debug("\(\#(literal: argument.description))")"#
    }
}

public struct DLogifyMacro: DeclarationMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
//        let s = "\"test"
//        let logline = "logger.debug(\(argument))"
//        
        return [
            DeclSyntax(
                stringLiteral: 
//                """
//                l()
//                """
                """
                logger.debug("testing macro: \\(\(argument))")
                """

            )
        ]
//        return []
        
//        return "\\\"\(raw: logline)\\\""
//        return #"logger.debug("\(\#(argument))")"#
//        return #"logger.debug("\(\#(literal: argument.description))")"#

    }
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
//        let s = "\"test"
        let logline = "logger.debug(\(argument))"
        
        return "\\\"\(raw: logline)\\\""
//        return #"logger.debug("\(\#(argument))")"#
//        return #"logger.debug("\(\#(literal: argument.description))")"#
    }
}



enum SlopSubsetError: CustomStringConvertible, Error {
    case onlyApplicableToEnum
    
    var description: String {
        switch self {
        case .onlyApplicableToEnum:
            return "@SlopeSubset can only be applied to an enum"
        }
    }
}
public struct SlopeSubsetMacro: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            //            // TODO: Diagnose
            //            return []
            throw SlopSubsetError.onlyApplicableToEnum
        }
        
        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }
        
        let initializer = try InitializerDeclSyntax(
            "init?(_ slope: Slope)"
        ) {
            try SwitchExprSyntax(
                "switch slope"
            ) {
                for element in elements {
                    SwitchCaseSyntax(
                        stringLiteral:
                        #"""
                        case .\#(element.name):
                            self = .\#(element.name)
                        """#
                    )
                }
                SwitchCaseSyntax(
                    stringLiteral:
                    #"""
                    default:
                        return nil
                    """#
                )
            }
        }
        
        //        let compProp = try VariableDeclSyntax("") {
        //
        //        }
        //        let c = try VariableDeclSyntax("") {
        //            StmtSyntax(
        //                stringLiteral:
        //            """
        //            var i: Int {
        //                0
        //            }
        //            """
        //            )
        //        }
        
        return [DeclSyntax(initializer)]
    }
}

public struct URLMacro: ExpressionMacro {
    
    enum URLMacroError: Error, CustomStringConvertible {
        case requiresStaticStringLiteral
        case malformedURL(urlString: String)
        
        var description: String {
            switch self {
            case .requiresStaticStringLiteral:
                return "#URL requires a static string literal"
            case .malformedURL(let urlString):
                return "The input URL is malformed: \(urlString)"
            }
        }
    }
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        //        print(node.argumentList.map { $0.expression })
        //        return "URL(string: \"https://www.avanderlee.com\")!"
        
        guard
            /// 1. Grab the first (and only) Macro argument.
            let argument = node.argumentList.first?.expression,
            /// 2. Ensure the argument contains of a single String literal segment.
            let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
            segments.count == 1,
            /// 3. Grab the actual String literal segment.
            case .stringSegment(let literalSegment)? = segments.first
        else {
            throw URLMacroError.requiresStaticStringLiteral
        }
        
        /// 4. Validate whether the String literal matches a valid URL structure.
        guard let _ = URL(string: literalSegment.content.text) else {
            throw URLMacroError.malformedURL(urlString: "\(argument)")
        }
        
        return "URL(string: \(argument))!"
    }
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



//public struct DictionaryStorageMacro: MemberMacro {
//    public static func expansion(
//        of attribute: AttributeSyntax,
//        providingMembersOf declaration: some DeclGroupSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [DeclSyntax] {
//        return [
//            "init(dictionary: [String: Any]) { self.dictionary = dictionary }",
//            "var dictionary: [String: Any]"
//        ]
//    }
//}


enum DebugLoggerError: CustomStringConvertible, Error {
    case notCorrectType

    var description: String {
        switch self {
        case .notCorrectType: return "@DebugLogger can only be applied to a class & struct"
        }
    }
}

/// Implementation of the `DebugLogger` macro, which takes a string
/// and prints the class and issue only during debugging. For example
///
///     @DebugLogger
///     class Foo {
///         func failure() {
///             ....
///             log(issue: "failed")
///         }
///     }
///
///  Will print out - "In Foo - failed"
public struct DebugLoggerMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // TODO: add type check for other DeclSyntax
        let identifier: TokenSyntax
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            identifier = classDecl.name
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            identifier = structDecl.name
        } else {
            throw DebugLoggerError.notCorrectType
        }

        // We could make issue generic but for now let's leave it as a string parameter
        let printFunc = try FunctionDeclSyntax("func log(issue: String)") {
            StmtSyntax(
                """
                
                    #if DEBUG
                    print(\"In \(raw: identifier.text) - \\(issue)\")
                    #endif
                """
            )
        }
        
        let s = try StmtSyntax(stringLiteral: "let i = 0")

        return [
            DeclSyntax(printFunc)
//            DeclSyntax(s)
        ]
    }
}
