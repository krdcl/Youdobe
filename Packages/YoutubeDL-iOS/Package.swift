// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "YoutubeDL-iOS",
    platforms: [
            .iOS(.v13),
    ],
    products: [
        .library(
            name: "YoutubeDL",
            targets: ["YoutubeDL"]),
    ],
    dependencies: [
        .package(path: "../FFmpeg-iOS"),
        .package(path: "../PythonKit"),
        .package(path: "../Python-iOS")
        
//        .package(url: "https://github.com/yuriisamoienko/FFmpeg-iOS.git", branch: "main"),
//        .package(url: "https://github.com/yuriisamoienko/PythonKit.git", branch: "master"),
//        .package(url: "https://github.com/yuriisamoienko/Python-iOS.git", branch: "kivy-ios"),
    ],
    targets: [
//        .binaryTarget(name: "avcodec", path: "../../Frameworks/avcodec.xcframework"),
//        .binaryTarget(name: "avutil", path: "../../Frameworks/avutil.xcframework"),
//        .binaryTarget(name: "avformat", path: "../../Frameworks/avformat.xcframework"),
//        .binaryTarget(name: "avfilter", path: "../../Frameworks/avfilter.xcframework"),
//        .binaryTarget(name: "avdevice", path: "../../Frameworks/avdevice.xcframework"),
//        .binaryTarget(name: "swscale", path: "../../Frameworks/swscale.xcframework"),
//        .binaryTarget(name: "swresample", path: "../../Frameworks/swresample.xcframework"),
        
        .target(
            name: "YoutubeDL",
            dependencies: [
//                "avcodec", "avutil", "avformat", "avfilter", "swscale", "swresample",
                "Python-iOS", "PythonKit", "FFmpeg-iOS"
            ]),
        .testTarget(
            name: "YoutubeDLTests",
            dependencies: ["YoutubeDL"]),
    ]
)
