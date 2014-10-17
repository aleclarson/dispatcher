
import Dispatch

public let gcd = Dispatcher()

public class Dispatcher : DispatchQueue {

  public var current: DispatchQueue {
    return Unmanaged<DispatchQueue>.fromOpaque(COpaquePointer(dispatch_get_specific(&kCurrentQueue))).takeUnretainedValue()
  }

  public let main = DispatchQueue(dispatch_get_main_queue())

  public let high = DispatchQueue(DISPATCH_QUEUE_PRIORITY_HIGH)

  public let low = DispatchQueue(DISPATCH_QUEUE_PRIORITY_LOW)

  public let background = DispatchQueue(DISPATCH_QUEUE_PRIORITY_BACKGROUND)

  public func serial () -> DispatchQueue {
    return DispatchQueue(false)
  }

  public func concurrent () -> DispatchQueue {
    return DispatchQueue(true)
  }

  init () { super.init(DISPATCH_QUEUE_PRIORITY_DEFAULT) }
}