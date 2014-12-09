
import UIKit
import XCTest
import Dispatcher

class JobTests : XCTestCase {

  func testPerform () {
    let e = expectationWithDescription(nil)

    Job.async {
      Queue.current.suspend()
      Timer(0.5) {
        Queue.current.resume()
      }
    }
  }
}