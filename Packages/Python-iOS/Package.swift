// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Python-iOS",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "Python-iOS",
            targets: [ // order matters!
                "LinkPython",
                "libpython3",
                //"libssl",
//                "libcrypto",
                "libffi",
                "PythonSupport",
            ]),
    ],
    targets: [
        .binaryTarget(name: "libpython3",   path: "../../Frameworks/libpython3.xcframework"),
//        .binaryTarget(name: "libssl",       path: "../../Frameworks/libssl.xcframework"),
//        .binaryTarget(name: "libcrypto",    path: "../../Frameworks/libcrypto.xcframework"),
        .binaryTarget(name: "libffi",       path: "../../Frameworks/libffi.xcframework"),
        .target(name: "LinkPython",
                dependencies: [
                    "libpython3",
//                    "libssl",
//                    "libcrypto",
                    "libffi",
                ],
                linkerSettings: [
                    .linkedLibrary("z"),
                    .linkedLibrary("sqlite3"),
                ]
        ),
        .target(name: "PythonSupport",
                dependencies: ["LinkPython"],
                resources: [.copy("lib")]),
        .testTarget(
            name: "PythonTests",
            dependencies: ["PythonSupport"]),
    ]
)
