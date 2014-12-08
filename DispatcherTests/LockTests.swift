
import XCTest
import Dispatcher

class LockTests : XCTestCase {

  override func setUp() {

  }

  override func tearDown() {

  }

  func testSerialLock () {
    let n = Lock(0)

    Queue.medium.async {
      n.lock { n in
        Queue.current.suspend()
        let _ = Timer(0.3) {
          XCTAssert(n == 0)
          n = 10
          Queue.current.resume()
        }
      }
    }

    Queue.low.async {
      XCTAssert(n.value == 10)
    }
  }
}
