
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

  func testCallbackQueue () {
    let e = expectationWithDescription(nil)
    
    gcd.async {
      self.timer = DispatchTimer(0.1) {
        XCTAssert(gcd.isCurrent)
        e.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.3, handler: nil)
  }

  func testFire () {
  
    timer = DispatchTimer(1, calls += 1)

    timer.fire()

    timer.fire() // Should not do anything.

    XCTAssert(calls == 1)
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

  func testAutoReleasedTimer () {
    let expectation = expectationWithDescription(nil)

    DispatchTimer(0.5, expectation.fulfill()).autorelease()

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testUnretainedTimer () {
    DispatchTimer(0.1, calls += 1)
    timer = DispatchTimer(0.2, XCTAssert(calls == 0))
  }

  func testThreadSafety () {
    let expectation = expectationWithDescription(nil)

    gcd.async {
      self.timer = Timer(0.5, gcd.main.sync(expectation.fulfill()))
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
