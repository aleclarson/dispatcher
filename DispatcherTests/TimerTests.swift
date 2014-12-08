
import UIKit
import XCTest
import Dispatcher

class TimerTests: XCTestCase {

  weak var timer: Timer!
  var calls = 0
  var view: UIView!

  override func tearDown() {
    timer = nil
    calls = 0
    super.tearDown()
  }

  func testTimer () {
    let expectation = expectationWithDescription(nil)

    timer = Timer(0.1, expectation.fulfill)

    waitForExpectationsWithTimeout(0.2, handler: nil)
  }

  func testCallbackQueue () {
    let e = expectationWithDescription(nil)
    
    Queue.medium.async {
      self.timer = Timer(0.1) {
        XCTAssert(Queue.medium.isCurrent)
        e.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.2, handler: nil)
  }

  func testFire () {
  
    timer = Timer(1) {
      self.calls += 1
      println("calls = \(self.calls)")
    }

    timer.fire()
    XCTAssert(calls == 1)

    timer.fire() // Should not do anything.
    XCTAssert(calls == 1)
  }

  func testFiniteRepeatingTimer () {
    let expectation = expectationWithDescription(nil)

    timer = Timer(0.25) {
      if ++self.calls == 2 { expectation.fulfill() }
    }

    timer.repeat(2)

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testInfiniteRepeatingTimer () {
    let expectation = expectationWithDescription(nil)

    timer = Timer(0.1) {
      if ++self.calls == 5 { expectation.fulfill() }
    }

    timer.repeat()

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testUnretainedTimer () {
    Timer(0.1) { self.calls += 1 }
    timer = Timer(0.2) { XCTAssert(self.calls == 0) }
  }

  func testThreadSafety () {
    let expectation = expectationWithDescription(nil)

    Queue.medium.async {
      self.timer = Timer(0.5) {
        Queue.main.sync {
          expectation.fulfill()
        }
      }
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testAccuracy () {
    let e = expectationWithDescription(nil)
    var actualDelay: CFAbsoluteTime!
    let expectedDelay: CFAbsoluteTime = 0.3
    let startTime = CFAbsoluteTimeGetCurrent()

    timer = Timer(Seconds(expectedDelay)) {
      Queue.medium.async {
        actualDelay = CFAbsoluteTimeGetCurrent() - startTime
        println("actualDelay = \(actualDelay)")
        XCTAssert(actualDelay == expectedDelay)
        e.fulfill()
      }
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
