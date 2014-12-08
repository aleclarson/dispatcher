
import XCTest
import Dispatcher

class LockTests : XCTestCase {

  override func setUp() {

  }

  override func tearDown() {

  }

  func testSerialLock () {
    let e = expectationWithDescription(nil)

    let start = 0
    let end = 10
    let current = Lock(start)

    Queue.medium.async {
      current.lock { current in
        Queue.current.suspend()
        let _ = Timer(0.3) {
          XCTAssert(current == start)
          current = end
          Queue.current.resume()
        }
      }
    }

    Queue.low.async {
      XCTAssert(current.value == end)
      e.fulfill()
    }

    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
