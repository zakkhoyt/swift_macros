// import Testing
// @testable import HatchConcurrencyMacrosImplementation

// @Test func example() async throws {
//     // Write your test here and use APIs like `#expect(...)` to check expected conditions.
// }



import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(HatchConcurrencyMacrosImplementation)
@testable import HatchConcurrencyMacrosImplementation

let asyncMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self
]

#endif

final class HatchConcurrencyMacrosImplementation: XCTestCase {
    func testAddAsync() {
#if canImport(HatchConcurrencyMacrosImplementation)
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
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}

