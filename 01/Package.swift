// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Zakkro",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .macCatalyst(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Zakkro",
            targets: ["Zakkro"]
        ),
        .executable(
            name: "ZakkroConsumer",
            targets: ["ZakkroConsumer"]
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
        .macro(
            name: "ZakkroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        // Macro tests (used during macro development)
        .testTarget(
            name: "ZakkroTests",
            dependencies: [
                "ZakkroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        // Exposes the macro via API (consumed by any code that depends on Zakkro)
        // import Zakkro
        .target(
            name: "Zakkro",
            dependencies: [
                "ZakkroMacros"
            ]
        ),
        
        // MARK - Macro Consumer Targets

        // A consumer of the macro library
        .executableTarget(
            name: "ZakkroConsumer",
            dependencies: [
                "Zakkro"
            ]
        ),
    ]
)
