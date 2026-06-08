// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Parla",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit", from: "0.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "Parla",
            dependencies: [
                .product(name: "WhisperKit", package: "WhisperKit"),
            ],
            path: "Sources/App",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
