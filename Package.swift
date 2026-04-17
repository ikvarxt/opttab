// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OptTab",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "OptTab", targets: ["OptTab"])
    ],
    targets: [
        .executableTarget(
            name: "OptTab"
        )
    ]
)
