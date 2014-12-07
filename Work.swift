
import CoreGraphics
import Dispatch

/// Tracks an arbitrary amount of work and notifies any callbacks when all work is completed.
public class Work {

  public init (_ amount: Int = 0) {
    for _ in 0..<amount { self++ }
  }

  public let core = dispatch_group_create()

  /// Called when all work is completed.
  public func done (callback: Void -> Void) {
    dispatch_group_notify(core, Queue.current.core, callback)
  }
}

public postfix func ++ (work: Work) {
  dispatch_group_enter(work.core)
}

public postfix func -- (work: Work) {
  dispatch_group_leave(work.core)
}
