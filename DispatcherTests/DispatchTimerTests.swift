
import UIKit
import XCTest
import Dispatcher

class DispatchTimerTests: XCTestCase {

  var timer: DispatchTimer!
  var calls = 0
  var view: UIView!

  override func tearDown() {
    timer = nil
    calls = 0
    super.tearDown()
  }

  func testDispatchTimer () {
    let expectation = expectationWithDescription(nil)

    timer = DispatchTimer(1, expectation.fulfill)

    waitForExpectationsWithTimeout(1.1, handler: nil)
  }

  func testFiniteRepeatingTimer () {
    let expectation = expectationWithDescription(nil)

    timer = DispatchTimer(0.25) {
      if ++self.calls == 2 { expectation.fulfill() }
    }

    timer.repeat(2)

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testInfiniteRepeatingTimer () {
    let expectation = expectationWithDescription(nil)

    timer = DispatchTimer(0.1) {
      if ++self.calls == 5 { expectation.fulfill() }
    }

    timer.repeat()

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testAutoClosureTimer () {
    let expectation = expectationWithDescription(nil)

    timer = DispatchTimer(0.1, expectation.fulfill())

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
