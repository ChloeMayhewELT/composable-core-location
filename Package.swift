// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "composable-core-location",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "ComposableCoreLocation",
      targets: ["ComposableCoreLocation"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMajor(from: "1.0.0")
    ),
    .package(
      url: "https://github.com/reddavis/Asynchrone",
      .upToNextMajor(from: "0.21.0")
    ),
  ],
  targets: [
    .target(
      name: "ComposableCoreLocation",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Asynchrone", package: "Asynchrone")
      ]
    ),
    .testTarget(
      name: "ComposableCoreLocationTests",
      dependencies: ["ComposableCoreLocation"]
    ),
  ]
)
