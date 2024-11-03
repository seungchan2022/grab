// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Platform",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "Platform",
      targets: ["Platform"]),
  ],
  dependencies: [
    .package(path: "../../Core/Domain"),
    .package(
      url: "https://github.com/apple/swift-log.git",
      .upToNextMajor(from: "1.5.3")),
    .package(
      url: "https://github.com/CombineCommunity/CombineExt.git",
      .upToNextMajor(from: "1.8.1")),
  ],
  targets: [
    .target(
      name: "Platform",
      dependencies: [
        "Domain",
        "CombineExt",
        .product(name: "Logging", package: "swift-log"),
      ]),
  ])
