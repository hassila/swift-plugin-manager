// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-plugin-manager",
    platforms: [
      .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PluginManager",
            targets: ["PluginManager"]),
        .library(
            name: "TestPluginExample",
            type: .dynamic,
            targets: ["TestPluginExample"]),
        .library(
            name: "TestPluginExampleActor",
            type: .dynamic,
            targets: ["TestPluginExampleActor"]),
        .library(
            name: "TestPluginManagerTestsInvalidPlugin",
            type: .dynamic,
            targets: ["TestPluginManagerTestsInvalidPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/hassila/swift-plugin", branch: "main")
    ],
    targets: [
        .target(
            name: "PluginManager",
            dependencies: [
              .product(name: "SystemPackage", package: "swift-system"),
              .product(name: "Logging", package: "swift-log"),
              .product(name: "Plugin", package: "swift-plugin"),
            ],
            swiftSettings: [
	          .unsafeFlags(["-Xfrontend", "-validate-tbd-against-ir=none"]) // due to https://bugs.swift.org/browse/SR-15629
            ]
        ),
        .target(
            name: "TestPluginExample",
            dependencies: ["TestPluginManagerExampleAPI",
                           "TestPluginExampleAPI",
                           .product(name: "Plugin", package: "swift-plugin"),
                          ]),
        .target(
            name: "TestPluginExampleActor",
            dependencies: ["TestPluginManagerExampleActorAPI",
                          "TestPluginExampleActorAPI",
                           .product(name: "Plugin", package: "swift-plugin"),
                          ]),
        .target(
            name: "TestPluginManagerTestsInvalidPlugin",
            dependencies: []),
        .target(
            name: "TestPluginManagerExampleAPI",
            dependencies: []),
        .target(
            name: "TestPluginManagerExampleActorAPI",
            dependencies: []),
        .target(
            name: "TestPluginExampleAPI",
            dependencies: [
              .product(name: "Plugin", package: "swift-plugin"),
              "TestPluginManagerExampleAPI"
        ]),
        .target(
            name: "TestPluginExampleActorAPI",
            dependencies: [
              .product(name: "Plugin", package: "swift-plugin"),
              "TestPluginManagerExampleActorAPI"
        ]),
        .testTarget(
            name: "PluginManagerTests",
            dependencies: ["PluginManager",
                           "TestPluginExampleAPI",
                           "TestPluginExampleActorAPI",
                           "TestPluginManagerExampleAPI",
                           "TestPluginManagerExampleActorAPI",
                           ]),
    ]
)
