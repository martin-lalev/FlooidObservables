// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FlooidObservables",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "FlooidObservables",
            targets: ["FlooidObservables"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlooidObservables",
            path: "FlooidObservables"),
    ]
)
