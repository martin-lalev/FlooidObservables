// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FlooidObservables",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "FlooidObservables",
            targets: ["FlooidObservables"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "FlooidObservables",
            dependencies: ["FlooidObservablesMacros"],
            path: "FlooidObservables",
            exclude: ["Info.plist"]
        ),
        .macro(
            name: "FlooidObservablesMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Macros"
        ),
    ],
    swiftLanguageVersions: [.v6]
)
