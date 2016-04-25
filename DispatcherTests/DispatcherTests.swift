
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
    queue.async {
      calls += 1
      XCTAssert(calls == 1)
    }
    queue.async {
      calls += 1
      XCTAssert(calls == 2)
    }
    queue.sync {
      calls += 1
      XCTAssert(calls == 3)
    }
  }

  func testSyncInSync () {
    var n = 0

    gcd.main.sync({gcd.main.sync({n += 1})})

    XCTAssert(n == 1)
  }

  func testAsyncInAsync () {
    let expectation = expectationWithDescription("")

    gcd.main.async({gcd.main.async({expectation.fulfill()})})

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
