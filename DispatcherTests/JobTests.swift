
import UIKit
import XCTest
import Dispatcher

class JobTests : XCTestCase {

  func testPerform () {

    let e = expectationWithDescription(nil)

    var calls = 0

    let job = JobVoid.async { _, done in
      let _ = Timer(0.5) {
        XCTAssert(++calls == 2)
        done()
      }
    }

    job.sync(Queue.high) { _ in
      let _ = Timer(0.5) {
        XCTAssert(++calls == 3)
        e.fulfill()
      }
    }

    job.perform()

    XCTAssert(++calls == 1)

    waitForExpectationsWithTimeout(2, handler: nil)
  }
}