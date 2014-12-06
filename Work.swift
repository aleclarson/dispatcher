
import CoreGraphics
import Dispatch

public class Work {

  public init (_ amount: Int = 0) {
    for _ in 0..<amount { self++ }
  }

  /// How much work is being done at this instant.
  public private(set) var amount = 0

  /// The wrapped dispatch_group_t
  public let wrapped = dispatch_group_create()

  /// Called when all work is completed.
  public func done (callback: Void -> Void) {
    dispatch_group_notify(wrapped, gcd.current.wrapped, callback)
  }
}

public postfix func ++ (work: Work) {
  lock(work) { work.amount++ }
  dispatch_group_enter(work.wrapped)
}

public postfix func -- (work: Work) {
  lock(work) { work.amount-- }
  dispatch_group_leave(work.wrapped)
}
