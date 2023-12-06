import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ZakkroMacros)
import ZakkroMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
]

let slopeMacros: [String: Macro.Type] = [
    "SlopeSubset": SlopeSubsetMacro.self,
]

let urlMacros: [String: Macro.Type] = [
    "URL": URLMacro.self // #URL should use URLMacro
]

let asyncMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self,
]


#endif

final class ZakkroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(ZakkroMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(ZakkroMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroWithSlopeSubset() throws {
        #if canImport(ZakkroMacros)
        assertMacroExpansion(
            #"""
            @SlopeSubset
            enum EasySlope {
                case beginnersParadise
                case practiceRun
            }
            """#,
            expandedSource: 
            #"""
            enum EasySlope {
                case beginnersParadise
                case practiceRun
            
                init?(_ slope: Slope) {
                    switch slope {
                    case .beginnersParadise:
                        self = .beginnersParadise
                    case .practiceRun:
                        self = .practiceRun
                    default:
                        return nil
                    }
                }
            }
            """#,
            macros: slopeMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
//    func testMacroWithDictionaryStorage() throws {
//        #if canImport(ZakkroMacros)
//        assertMacroExpansion(
//            #"""
//            #stringify("Hello, \(name)")
//            """#,
//            expandedSource: #"""
//            ("Hello, \(name)", #""Hello, \(name)""#)
//            """#,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }

    func testSlopeSubsetOnStruct() throws {
        assertMacroExpansion(
            """
            @SlopeSubset
            struct Skier {
            }
            """,
            expandedSource:
            """
            struct Skier {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@SlopeSubset can only be applied to an enum", line: 1, column: 1)
            ],
            macros: slopeMacros
        )
    }
    
    
    func testValidURL() {
        assertMacroExpansion(
            #"""
            #URL("https://www.avanderlee.com")
            """#,
            expandedSource: #"""
            URL(string: "https://www.avanderlee.com")!
            """#,
            macros: urlMacros
        )
    }
    
    func testAddAsync() {
        assertMacroExpansion(
            """
            @AddAsync
            func test(arg1: String, completion: (String?) -> Void) {
            }
            """,
            expandedSource: """
            
            func test(arg1: String, completion: (String?) -> Void) {
            }
            
            func test(arg1: String) async -> String? {
                await withCheckedContinuation { continuation in
                    self.test(arg1: arg1) { object in
                        continuation.resume(returning: object)
                    }
                }
            }
            """,
            macros: asyncMacros
        )
    }
}





