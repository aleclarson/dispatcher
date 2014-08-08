
let gcd = Dispatcher()

class Dispatcher {
  
  /// dispatch_get_main_queue()
  let main = DispatchQueue("main")
  
  /// DISPATCH_QUEUE_PRIORITY_DEFAULT
  let global = DispatchQueue("global")
  
  /// DISPATCH_QUEUE_PRIORITY_BACKGROUND
  let background = DispatchQueue("background")
  
  /// DISPATCH_QUEUE_PRIORITY_LOW
  let low = DispatchQueue("low")
  
  /// DISPATCH_QUEUE_PRIORITY_HIGH
  let high = DispatchQueue("high")
  
  /// DISPATCH_QUEUE_SERIAL
  func serial (id: String) -> DispatchQueue {
    let queue = DispatchQueue(id)
    queue.q = dispatch_queue_create(id, DISPATCH_QUEUE_SERIAL)
    return queue
  }
  
  /// DISPATCH_QUEUE_CONCURRENT
  func concurrent (id: String) -> DispatchQueue {
    let queue = DispatchQueue(id)
    queue.q = dispatch_queue_create(id, DISPATCH_QUEUE_CONCURRENT)
    return queue
  }
  
  private init () {
    main.q = dispatch_get_main_queue()
    global.q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    background.q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    high.q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    low.q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
  }
}

private var queueIDs = [String:Void]()

class DispatchQueue {

  private init (_ id: String) {
    if queueIDs[id] != nil { fatalError("The 'id' provided is already in use!") }
    queueIDs[id] = ()
    self.id = id
  }
  
  let id: String
  
  func async (block: dispatch_block_t) {
    dispatch_async(q, block)
  }
  
  func async (block: @autoclosure () -> ()) {
    async { block() }
  }
  
  func sync (block: dispatch_block_t) {
    dispatch_sync(q, block)
  }
  
  func sync (block: @autoclosure () -> ()) {
    sync { block() }
  }
  
  /// A lower level of abstraction
  private(set) var q: dispatch_queue_t!
}

class DispatchGroup {

  private(set) var count = 0
  
  convenience init(_ count: Int) {
    self.init()
    self += count
  }
  
  /// dispatch_group_notify()
  func onFinish (block: () -> ()) {
    dispatch_group_notify(g, gcd.global.q, block)
  }
  
  /// Lower level of abstraction
  private(set) var g = dispatch_group_create()
}

/// dispatch_group_enter()
func += (lhs: DispatchGroup, rhs: Int) {
  lhs.count += rhs
  for _ in 0..<rhs {
    dispatch_group_enter(lhs.g)
  }
}

/// dispatch_group_leave()
func -= (lhs: DispatchGroup, rhs: Int) {
  var count = rhs > lhs.count ? lhs.count : rhs
  lhs.count -= count
  for _ in 0..<count {
    dispatch_group_leave(lhs.g)
  }
}
