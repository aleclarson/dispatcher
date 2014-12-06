
import Dispatch

/// A default-priority Queue that also provides access to the main Queue, 
/// the 3 global Queues, and the ability to create your own Queues.
public let gcd = Dispatcher()

public class Dispatcher : Queue {

  /// Returns `nil` if the current Thread was not created by a Queue; normally this doesn't happen.
  public var current: Queue! {
    let queue = dispatch_get_specific(&kQueueCurrentKey)
    if queue == nil { return nil }
    return Unmanaged<Queue>.fromOpaque(COpaquePointer(queue)).takeUnretainedValue()
  }

  public let main = Queue()

  public let high = Queue(DISPATCH_QUEUE_PRIORITY_HIGH)

  public let low = Queue(DISPATCH_QUEUE_PRIORITY_LOW)

  public let background = Queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND)



  // MARK: Methods

  /// Creates a new Queue that executes one block at a time.
  public func serial (_ priority: Priority = .Normal) -> Queue {
    return Queue(true, priority)
  }

  /// Creates a new Queue that executes multiple blocks at once.
  public func concurrent (_ priority: Priority = .Normal) -> Queue {
    return Queue(false, priority)
  }



  // MARK: Private

  private override init () {
    super.init(DISPATCH_QUEUE_PRIORITY_DEFAULT)
  }
}
