import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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

@main
struct ZakkroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        SlopeSubsetMacro.self,
        URLMacro.self
    ]
}
