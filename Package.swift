// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppIconGenerator",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AppIconGenerator",
            dependencies: [],
            path: ".",
            sources: [
                "AppIconGeneratorApp.swift",
                "ContentView.swift",
                "IconGeneratorViewModel.swift"
            ]
        )
    ]
)
