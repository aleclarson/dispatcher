
import UIKit
import XCTest
import Dispatcher

class DispatcherTests: XCTestCase {

  func testQueueIsCurrent () {
    XCTAssert(!gcd.isCurrent)
    gcd.sync { XCTAssert(gcd.isCurrent) }
  }

  func testDispatcherCurrent () {
    XCTAssert(gcd.main === gcd.current)
    gcd.sync { XCTAssert(gcd.main !== gcd.current) }
  }

  func testDispatcherPrevious () {

    let expectation = expectationWithDescription(nil)

    gcd.async {
      XCTAssert(gcd.previous === gcd.main)
      gcd.main.sync {
        XCTAssert(gcd.previous === gcd)
        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.5, handler: nil)
  }

  func testSerialQueue () {

    var n = 0

    let queue = gcd.serial()

    queue.async { XCTAssert(++n == 1) }

    queue.async { XCTAssert(++n == 2) }

    queue.sync { XCTAssert(++n == 3) }
  }

  func testCurrentSync () {

    var n = 0

    XCTAssert(gcd.current === gcd.main)

    gcd.main.sync(n += 1)

    XCTAssert(n == 1)
  }

  func testSuspendAndResume () {

    let expectation = expectationWithDescription(nil)

    let q = gcd.serial()

    q.suspend()

    q.async(expectation.fulfill())

    q.resume()

    waitForExpectationsWithTimeout(0.5, handler: nil)
  }

  // Ideally, this test should fail. But this issue is not yet fixed. Though it is uncommon.
//  func testSyncInSync () {
//
//    let expectation = expectationWithDescription(nil)
//
//    gcd.high.async(gcd.sync(gcd.background.sync(gcd.sync(expectation.fulfill()))))
//
//    waitForExpectationsWithTimeout(0.5) { XCTAssertNotNil($0) }
//  }

  func testAsyncInAsync () {

    let expectation = expectationWithDescription(nil)

    gcd.main.async(gcd.main.async(expectation.fulfill()))

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
