// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KSPlayer",
    defaultLocalization: "en",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "KSPlayer",
            targets: ["KSPlayer", "FFmpeg"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        .target(
            name: "KSPlayer",
            dependencies: ["FFmpeg"],
            resources: [.process("Core/Resources"), .process("Metal/Shaders.metal")],
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreImage"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("MetalKit"),
                .linkedFramework("Security"),
                .linkedFramework("VideoToolbox"),
            ]
        ),
        .target(
            name: "FFmpeg",
            dependencies: [
                "avcodec", "avfilter", "avformat", "avutil", "swresample", "swscale",
                "libssl",
                //"Libcrypto"
            ],
            linkerSettings: [
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
            ]
        ),
        .executableTarget(
            name: "BuildFFmpeg",
            dependencies: []
        ),
        .testTarget(
            name: "KSPlayerTests",
            dependencies: ["KSPlayer"],
            resources: [.process("Resources")]
        ),
        
        .binaryTarget(name: "avcodec", path: "../../Frameworks/avcodec.xcframework"),
        .binaryTarget(name: "avutil", path: "../../Frameworks/avutil.xcframework"),
        .binaryTarget(name: "avformat", path: "../../Frameworks/avformat.xcframework"),
        .binaryTarget(name: "avfilter", path: "../../Frameworks/avfilter.xcframework"),
        .binaryTarget(name: "avdevice", path: "../../Frameworks/avdevice.xcframework"),
        .binaryTarget(name: "swscale", path: "../../Frameworks/swscale.xcframework"),
        .binaryTarget(name: "swresample", path: "../../Frameworks/swresample.xcframework"),
        
        .binaryTarget(
            name: "libssl",
            path: "../../Frameworks/libssl.xcframework"
        ),
//        .binaryTarget(
//            name: "Libcrypto",
//            path: "../../Frameworks/Libcrypto.xcframework"
//        ),
    ]
)
