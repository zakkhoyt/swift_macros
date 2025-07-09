# Swift Macros

* [Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
* [hackingwithswift](https://www.hackingwithswift.com/swift/5.9/macros)
* [swiftylion](https://swiftylion.com/articles/swift-macros)
* [3rd party article](https://www.avanderlee.com/swift/macros/)

* [Apple (get source code info)](https://developer.apple.com/documentation/swift/file())

* [SwiftSyntax](https://swiftpackageindex.com/apple/swift-syntax/509.0.2/documentation/swiftsyntax)
* [SwiftSyntaxBuilder](https://github.com/apple/swift-syntax/tree/main/Sources/SwiftSyntaxBuilder)
* [SwiftSyntaxBuilder](https://swiftinit.org/docs/swift-syntax/swiftsyntax/exprsyntax)

`opt` + click on a macro to see documentation

2 types of macros:
* Freestanding: begins with `#`
* Attaches: Begins with `@`

Can break/debug into macros
Can write tests for macros

## Roles (You can compose multiple roles)
* `@freestanding (expression)` 
  * Creates a piece of code that returns a value
  * `ExpressionMacro`
* `@freestanding (declaration)` 
  * Creates one or more declarations
  * `DeclarationMacro`
* `@attached (peer)` 
  * Adds new declarations alongside the declaration it's applied to
  * `PeerMacro`
* `@attached (accessor)` 
  * Adds accessors to a property
  * `AccessorMacro`
* `@attached (memberAttribute)` 
  * Adds attributes to the declarations in the type/extension it's app
  * `MemberAttributeMacro`
* `@attached (member)` 
  * Adds new declarations inside the type/extension it's applied to
  * `MemberMacro`
* `@attached (conformance)` 
  * Adds contormances to the type/extension it's applied to
  * `ConformanceMacro`

## Implementation
* `#externalMacro`

* Declaration goes in normal SPM module
* Implementation goes in its own `.macro` module 

* SwiftSyntax is a big part of learning. 


### Return typs
* `DeclSyntaxProtocol`



### Debugging / Breakpoints
* How to debug a macro? I want to break/inspect `DeclGroupSyntax`, `MacroExpansionContext`, etc..
  * See 19:50 in this [WWDC video](https://developer.apple.com/wwdc23/10166) 
  * You have to set a breakpoint inside the  macro expansion function, then hit that BP by running the unit test (mandatory)
  * `(lldb) po declaration`

```
EnumDeclSyntax
├─attributes: AttributeListSyntax
│ ╰─[0]: AttributeSyntax
│   ├─atSign: atSign
│   ╰─attributeName: IdentifierTypeSyntax
│     ╰─name: identifier("SlopeSubset")
├─modifiers: DeclModifierListSyntax
├─enumKeyword: keyword(SwiftSyntax.Keyword.enum)
├─name: identifier("EasySlope")
╰─memberBlock: MemberBlockSyntax
  ├─leftBrace: leftBrace
  ├─members: MemberBlockItemListSyntax
  │ ├─[0]: MemberBlockItemSyntax
  │ │ ╰─decl: EnumCaseDeclSyntax
  │ │   ├─attributes: AttributeListSyntax
  │ │   ├─modifiers: DeclModifierListSyntax
  │ │   ├─caseKeyword: keyword(SwiftSyntax.Keyword.case)
  │ │   ╰─elements: EnumCaseElementListSyntax
  │ │     ╰─[0]: EnumCaseElementSyntax
  │ │       ╰─name: identifier("beginnersParadise")
  │ ╰─[1]: MemberBlockItemSyntax
  │   ╰─decl: EnumCaseDeclSyntax
  │     ├─attributes: AttributeListSyntax
  │     ├─modifiers: DeclModifierListSyntax
  │     ├─caseKeyword: keyword(SwiftSyntax.Keyword.case)
  │     ╰─elements: EnumCaseElementListSyntax
  │       ╰─[0]: EnumCaseElementSyntax
  │         ╰─name: identifier("practiceRun")
  ╰─rightBrace: rightBrace
```
### Throwing Errors and Help
Throw errors using Diagnostic. 
context.diagnose(Diagnostic(...))


## Ideas
* completionn / async 
* Span/trace
* OSlog + remote 


## Examples
* [From WWDC](https://developer.apple.com/wwdc23/10166), we will do the ski slop example (adds an init and computed property to enums) 


## Questions
* how to pass parameters into a macro. Suppose a macro for logging a var. How to pass a message in with it?




DeclarationMacro
https://medium.com/@tahabebek/swift-macros-36417a8557a
