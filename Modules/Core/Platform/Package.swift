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
    .package(path: "../../Core/Architecture"),
    .package(path: "../../Core/Domain"),
    .package(
      url: "https://github.com/apple/swift-log.git",
      .upToNextMajor(from: "1.5.3")),
    .package(
      url: "https://github.com/CombineCommunity/CombineExt.git",
      .upToNextMajor(from: "1.8.1")),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      .upToNextMajor(from: "11.5.0")),
    .package(
      url: "https://github.com/kakao/kakao-ios-sdk.git",
      .upToNextMajor(from: "2.23.0")),
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS",
      .upToNextMajor(from: "8.0.0")),
  ],
  targets: [
    .target(
      name: "Platform",
      dependencies: [
        "Architecture",
        "Domain",
        "CombineExt",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
        .product(name: "KakaoSDK", package: "kakao-ios-sdk"),
        .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
        .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
        .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
      ]),
  ])
