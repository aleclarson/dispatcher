
/// Synchronizes a resource across threads.
/// All operations block each other.
public class Lock {

  public func read <T> (block: Void -> T) -> T {
    return lock(self, block)
  }

  public func write (block: Void -> Void) {
    lock(self, block)
  }
}

/// Synchronizes a resource across threads.
/// Write operations block everyone.
/// Read operations are concurrent.
public class WriteLock : Lock {

  public override func read <T> (block: Void -> T) -> T {
    var value: T!
    queue.sync { value = block() }
    return value
  }

  public override func write (block: Void -> Void) {
    queue.barrier(block)
  }

  private let queue = gcd.concurrent(gcd.current.priority)
}

/// Lock a resource based on an object.
public func lock <T> (obj: AnyObject, block: Void -> T) -> T {
  objc_sync_enter(obj)
  let value = block()
  objc_sync_exit(obj)
  return value
}
