
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
        Timer(0.5) {
          XCTAssert(n)
        }
      }
    }

    Queue.low.async {

    }

    Queue.background.async {

    }
  }
}
