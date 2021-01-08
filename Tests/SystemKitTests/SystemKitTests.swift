import XCTest
@testable import SystemKit

final class SystemKitTests: XCTestCase {

    func testPosixPermissions() {
        let a: PosixPermissions = [.readableByOwner,
                                   .readableByGroup,
                                   .writableByOwner,
                                   .executableByOwner,
                                   .executableByGroup,
                                   .executableByOthers]
        XCTAssertEqual(a.rawValue, 0o751)
    }
    
    func testStopWatch() {
        let stopWatch = StopWatch.started()
        Thread.sleep(forTimeInterval: 0.4)
        let time = stopWatch.stop()
        XCTAssertTrue(time > 0.4 && time < 1)
    }
    
    static var allTests = [
        ("testPosixPermissions", testPosixPermissions),
        ("testStopWatch", testStopWatch),
    ]
}
