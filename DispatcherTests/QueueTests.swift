
import UIKit
import XCTest
import Dispatcher

class QueueTests: XCTestCase {

  func testQueueIsCurrent () {
    XCTAssert(!Queue.medium.isCurrent)
    Queue.medium.sync { XCTAssert(Queue.medium.isCurrent) }
  }

  func testQueueCurrent () {
    XCTAssert(Queue.main.isCurrent)
    Queue.medium.sync { XCTAssert(Queue.main !== Queue.current) }
  }

  func testSerialQueue () {

    var n = 0

    let queue = Queue.serial()

    queue.async { XCTAssert(++n == 1) }

    queue.async { XCTAssert(++n == 2) }

    queue.sync { XCTAssert(++n == 3) }
  }

  // Ensure a deadlock does not occur when `Queue.sync()` is used when `Queue.isCurrent` is `true`.
  func testCurrentSync () {

    var n = 0

    XCTAssert(Queue.current === Queue.main)

    Queue.main.sync { n += 1 }

    XCTAssert(n == 1)
  }

  func testSuspendAndResume () {

    let expectation = expectationWithDescription(nil)

    let q = Queue.serial()

    q.suspend()

    q.async { expectation.fulfill() }

    q.resume()

    waitForExpectationsWithTimeout(0.5, handler: nil)
  }

  // Ideally, this test should fail. But this issue is not yet fixed.
  // But this situation is rare for most people.
//  func testSyncInSync () {
//
//    let expectation = expectationWithDescription(nil)
//
//    Queue.high.async {
//      Queue.medium.sync {
//        Queue.background.sync {
//          Queue.medium.sync {
//            expectation.fulfill()
//          }
//        }
//      }
//    }
//
//    waitForExpectationsWithTimeout(0.5) { XCTAssertNotNil($0) }
//  }

  func testAsyncInAsync () {

    let expectation = expectationWithDescription(nil)

    Queue.main.async {
      Queue.main.async {
        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
