// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FlooidObservables",
    platforms: [.iOS(.v13)],
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
            path: "FlooidObservables",
            exclude: ["Info.plist"]
        ),
    ]
)
