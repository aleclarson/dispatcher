
import CoreGraphics
import Dispatch

public class Work {

  public init (_ amount: Int = 0) {
    for _ in 0..<amount { self++ }
  }

  public let core = dispatch_group_create()

  /// Called when all work is completed.
  public func done (callback: Void -> Void) {
    dispatch_group_notify(core, gcd.current.core, callback)
  }
}

public postfix func ++ (work: Work) {
  dispatch_group_enter(work.core)
}

public postfix func -- (work: Work) {
  dispatch_group_leave(work.core)
}
