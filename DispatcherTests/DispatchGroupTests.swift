
import UIKit
import XCTest
import Dispatcher

class WorkTests: XCTestCase {

  var group: Work!

  override func tearDown() {
    group = nil
    super.tearDown()
  }

  func testWork () {
    let expectation = expectationWithDescription(nil)

    group = Work()

    group++

    group.done(expectation.fulfill)

    group--

    waitForExpectationsWithTimeout(1) { XCTAssertNil($0) }
  }

  func testThreadSafety () {
    let expectation = expectationWithDescription(nil)

    group = Work(2)

    gcd.async {
      self.group--
      gcd.main.sync {
        self.group--
      }
    }

    group.done(expectation.fulfill)

    waitForExpectationsWithTimeout(1) { XCTAssertNil($0) }
  }
}
