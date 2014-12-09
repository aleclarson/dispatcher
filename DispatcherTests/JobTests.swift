
import UIKit
import XCTest
import Dispatcher

class JobTests : XCTestCase {

  func testPerform () {
    let e = expectationWithDescription(nil)

    Job.async {
      (_: Void, done: Void -> Void) in
      Timer(0.5, done)
    }.
  }
}