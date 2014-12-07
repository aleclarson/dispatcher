
import UIKit
import XCTest
import Dispatcher

class DispatcherTests: XCTestCase {

  func testDispatchQueueIsCurrent () {
    XCTAssert(gcd.main.isCurrent)
    XCTAssert(!gcd.isCurrent)
    gcd.sync { XCTAssert(gcd.isCurrent) }
  }

  func testDispatcherCurrent () {
    XCTAssert(gcd.main === gcd.current)
    XCTAssert(gcd !== gcd.current)
    gcd.sync { XCTAssert(gcd === gcd.current) }
  }

  func testSerialDispatchQueue () {
    var calls = 0
    let queue = gcd.serial()
    queue.async { XCTAssert(++calls == 1) }
    queue.async { XCTAssert(++calls == 2) }
    queue.sync { XCTAssert(++calls == 3) }
  }

  func testDispatchGroup () {
    let expectation = expectationWithDescription(nil)

    let group = DispatchGroup(1)
    ++group
    gcd.async { --group }
    group.done(expectation.fulfill)
    --group

    waitForExpectationsWithTimeout(2) { XCTAssertNil($0) }
  }
}
