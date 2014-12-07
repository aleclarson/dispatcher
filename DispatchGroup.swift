
import Dispatch

public prefix func ++ (group: DispatchGroup) {
  dispatch_group_enter(group.dispatch_group)
}

public prefix func -- (group: DispatchGroup) {
  dispatch_group_leave(group.dispatch_group)
}

public class DispatchGroup {

  public let dispatch_group = dispatch_group_create()
  
  public init (_ tasks: Int = 0) {
    for _ in 0..<tasks { ++self }
  }
  
  public func done (handler: Void -> Void) {
    dispatch_group_notify(dispatch_group, gcd.current.dispatch_queue, handler)
  }
}
