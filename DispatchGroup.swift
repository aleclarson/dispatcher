
import CoreGraphics
import Dispatch

public typealias Group = DispatchGroup

public class DispatchGroup {

  public init (_ tasks: Int = 0) {
    for _ in 0..<tasks { ++self }
  }

  public private(set) var tasks = 0

  public let dispatch_group = dispatch_group_create()
  
  public func done (callback: Void -> Void) {
    dispatch_group_notify(dispatch_group, gcd.current.dispatch_queue, callback)
  }

  public func wait (delay: CGFloat, _ callback: Void -> Void) {
    dispatch_group_wait(dispatch_group, dispatch_time(DISPATCH_TIME_NOW, Int64(delay * CGFloat(NSEC_PER_SEC))))
  }

  deinit { assert(tasks == 0, "A DispatchGroup cannot be deallocated when tasks is greater than zero!") }
}

public prefix func ++ (group: DispatchGroup) {
  objc_sync_enter(group)
  group.tasks += 1
  dispatch_group_enter(group.dispatch_group)
  objc_sync_exit(group)
}

public prefix func -- (group: DispatchGroup) {
  objc_sync_enter(group)
  group.tasks -= 1
  dispatch_group_leave(group.dispatch_group)
  objc_sync_exit(group)
}

public postfix func ++ (group: DispatchGroup) {
  ++group
}

public postfix func -- (group: DispatchGroup) {
  --group
}
