
import UIKit
import XCTest
import Dispatcher

class DispatchGroupTests: XCTestCase {

  var group: DispatchGroup!

  override func tearDown() {
    group = nil
    super.tearDown()
  }

  func testDispatchGroup () {
    let expectation = expectationWithDescription("")

    group = DispatchGroup()

    group++

    group.done(expectation.fulfill)

    group--

    waitForExpectationsWithTimeout(1) { XCTAssertNil($0) }
  }

  func testThreadSafety () {
    let expectation = expectationWithDescription("")

    group = DispatchGroup(2)

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
