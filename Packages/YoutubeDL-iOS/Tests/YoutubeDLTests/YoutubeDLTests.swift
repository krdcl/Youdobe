import XCTest
@testable import YoutubeDL

final class YoutubeDLTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        _ = try? YoutubeDL()
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
