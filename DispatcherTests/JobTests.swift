
import UIKit
import XCTest
import Dispatcher

class JobTests : XCTestCase {

  func testPerform () {
    let e = expectationWithDescription(nil)
    var calls = 0

    let job = JobVoid.async {
      let _ = Timer(0.1) { XCTAssert(++calls == 2); done() }
    }

    j.async(Queue.high) {
      (_: Void, done: Void -> Void) in
      let _ = Timer(0.1) { XCTAssert(++calls == 3); done() }
    }

    job.perform()
    XCTAssert(++calls == 1)

    waitForExpectationsWithTimeout(0.5, handler: nil)
  }
}