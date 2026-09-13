// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PDDropDownSwitfUI",

    platforms: [
        .iOS(.v15)
    ],

    products: [
        .library(
            name: "PDDropDownSwitfUI",
            targets: ["PDDropDownSwitfUI"]
        )
    ],

    targets: [
        .target(
            name: "PDDropDownSwitfUI",
            path: "Sources/PDDropDownSwitfUI"
        )
    ]
)