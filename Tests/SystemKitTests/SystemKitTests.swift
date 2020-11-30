import XCTest
@testable import SystemKit

final class SystemKitTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(true, true)
    }

    func testPosixPermissions() {
        let a: PosixPermissions = [.readableByOwner,
                                   .readableByGroup,
                                   .writableByOwner,
                                   .executableByOwner,
                                   .executableByGroup,
                                   .executableByOthers]
        XCTAssertEqual(a.rawValue, 0o751)
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testPosixPermissions", testPosixPermissions)
    ]
}
