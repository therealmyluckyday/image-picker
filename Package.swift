// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ImagePicker",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "ImagePicker",
            targets: [
                "ImagePicker"
            ]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "ImagePicker",
            dependencies: [],
            path: "ImagePicker"
        )
    ]
)
