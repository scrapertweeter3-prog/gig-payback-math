// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GigPaybackMath",
    products: [
        .library(name: "GigPaybackMath", targets: ["GigPaybackMath"])
    ],
    targets: [
        .target(name: "GigPaybackMath")
    ]
)
