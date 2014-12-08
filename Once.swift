
public func once (task: Void -> Void, file: String = __FILE__, line: Int = __LINE__) {
  let id = "\(file)\(line)"
  if onces[id] == nil { return }
  onces[id] = Once(task)
}

private class Once {

  init (_ task: Void -> Void) {
    dispatch_once(&token, task)
  }

  var token = dispatch_once_t()
}

private var onces = [String:Once]()
