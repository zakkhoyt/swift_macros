// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "HatchMacros",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HatchConcurrencyMacros",
            targets: ["HatchConcurrencyMacros"]
        ),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        // https://github.com/swiftlang/swift-syntax/releases
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0"
        ),
    ],
    targets: [
        // MARK - Macro Targets
    
        // The Macro implementation that performs the source transformation
        // Requires `import CompilerPluginSupport` above
        .macro(
            name: "HatchConcurrencyMacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        // Macro tests (used during macro development)
        .testTarget(
            name: "ZakkroTests",
            dependencies: [
                "HatchConcurrencyMacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        // Exposes the macro via API (consumed by any code that depends on Zakkro)
        // import Zakkro
        .target(
            name: "HatchConcurrencyMacros",
            dependencies: [
                "HatchConcurrencyMacrosImplementation"
            ]
        ),
        
        // // MARK - Macro Consumer Targets

        // // A consumer of the macro library
        // .executableTarget(
        //     name: "ZakkroConsumer",
        //     dependencies: [
        //         "Zakkro"
        //     ]
        // ),
    ]
)