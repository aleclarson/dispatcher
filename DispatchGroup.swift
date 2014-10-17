
public prefix func ++ (group: DispatchGroup) {
  ++group.tasksRemaining
}

public prefix func -- (group: DispatchGroup) {
  if group.tasksRemaining == 0 { return }
  --group.tasksRemaining
  ++group.tasksCompleted
  if group.tasksRemaining == 0 { group.onDone?() }
}

public class DispatchGroup {

  public private(set) var tasksRemaining: Int
  
  public private(set) var tasksCompleted = 0
  
  public init (_ tasks: Int = 0) {
    tasksRemaining = tasks
  }
  
  public func done (handler: Void -> Void) {
    if tasksRemaining > 0 { onDone = handler }
    else { handler() }
  }
  
  var onDone: (Void -> Void)?
}
