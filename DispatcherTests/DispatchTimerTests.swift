
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
    let expectation = expectationWithDescription("")

    timer = DispatchTimer(1, expectation.fulfill)

    waitForExpectationsWithTimeout(1.1, handler: nil)
  }

  func testCallbackQueue () {
    let e = expectationWithDescription("")
    
    gcd.async {
      self.timer = DispatchTimer(0.1) {
        XCTAssert(gcd.isCurrent)
        e.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.3, handler: nil)
  }

  func testFire () {
  
    timer = DispatchTimer(1, {self.calls += 1})

    timer.fire()

    timer.fire() // Should not do anything.

    XCTAssert(calls == 1)
  }

  func testFiniteRepeatingTimer () {
    let expectation = expectationWithDescription("")

    timer = DispatchTimer(0.25) {
      self.calls += 1
      if self.calls == 2 {
        expectation.fulfill()
      }
    }

    timer.doRepeat(2)

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testInfiniteRepeatingTimer () {
    let expectation = expectationWithDescription("")

    timer = DispatchTimer(0.1) {
      self.calls += 1
      if self.calls == 5 {
        expectation.fulfill()
      }
    }

    timer.doRepeat()

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testAutoClosureTimer () {
    let expectation = expectationWithDescription("")

    timer = DispatchTimer(0.1, {expectation.fulfill()})

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testAutoReleasedTimer () {
    let expectation = expectationWithDescription("")

    DispatchTimer(0.5, {expectation.fulfill()}).autorelease()

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testUnretainedTimer () {
    let _ = DispatchTimer(0.1, {self.calls += 1})
    timer = DispatchTimer(0.2, {XCTAssert(self.calls == 0)})
  }

  func testThreadSafety () {
    let expectation = expectationWithDescription("")

    gcd.async {
      self.timer = Timer(0.5, gcd.main.sync({expectation.fulfill()}))
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
