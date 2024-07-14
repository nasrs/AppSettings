// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppSettings",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppSettings",
            targets: ["AppSettings"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "AppSettings"),
        .testTarget(name: "AppSettingsTests",
                    dependencies: [
                        "AppSettings",
                        "ViewInspector"
                    ],
                    resources: [
                        .process("Resources")
                    ]),
    ]
)
