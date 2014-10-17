
import UIKit
import XCTest
import Dispatcher

class DispatcherTests: XCTestCase {

  override func setUp () {
    super.setUp()
  }

  override func tearDown () {
    super.tearDown()
  }

  func testIsCurrent () {
    XCTAssert(gcd.main.isCurrent)
    XCTAssert(!gcd.isCurrent)
    gcd.sync { XCTAssert(gcd.isCurrent) }
  }

  func testCurrent () {
    XCTAssert(gcd.main === gcd.current)
    XCTAssert(gcd !== gcd.current)
    gcd.sync { XCTAssert(gcd === gcd.current) }
  }

  func testSerial () {
    var calls = 0
    let queue = gcd.serial()
    queue.async { XCTAssert(++calls == 1) }
    queue.async { XCTAssert(++calls == 2) }
    queue.sync { XCTAssert(++calls == 3) }
  }
}
