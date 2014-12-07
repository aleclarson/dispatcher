
import Foundation

/// Both serial and concurrent Queues do not guarantee the same Thread is used every time.
/// An exception is made for the main Queue, which always uses the main Thread.
public class Queue {

  // MARK: Public

  /// This can only be set if this Queue is serial and created by you.
  public var priority: Priority {
    willSet {
      assert(!isBuiltin, "not allowed to set the priority of a built-in queue")
      dispatch_set_target_queue(core, newValue.builtin.core)
    }
  }

  public var isCurrent: Bool { return dispatch_get_specific(&kQueueCurrentKey) == getMutablePointer(self) }

  /// If `true`, this Queue always executes one block at a time.
  public let isSerial: Bool

  /// If `true`, this Queue wraps around the main UI queue.
  public var isMain: Bool { return self === gcd.main }

  /// If `true`, this Queue wraps around one of Apple's built-in dispatch queues.
  public let isBuiltin: Bool

  

  // MARK: Methods

  /// Calls the callback asynchronously on this queue.
  public func async (block: Void -> Void) {
    dispatch_async(core) { block() }
  }

  /// If this queue is the current queue, the callback is called immediately.
  /// Else, the callback is called synchronously on this queue.
  public func sync (block: Void -> Void) {
    isCurrent ? block() : dispatch_sync(core) { block() }
  }

  /// If this queue is the current queue, the callback is called immediately.
  /// Else, the callback is called asynchronously on this queue.
  public func csync (block: Void -> Void) {
    isCurrent ? block() : async(block)
  }

  public func suspend () {
    dispatch_suspend(core)
  }

  public func resume () {
    dispatch_resume(core)
  }

  /// Asynchronously submits a barrier block to this Queue.
  public func barrier (block: Void -> Void) {
    assert(!isSerial, "a barrier is pointless on a serial queue")
    assert(!isBuiltin, "a barrier cannot be used on a built-in queue")
    dispatch_barrier_async(core, block)
  }

  public let core: dispatch_queue_t



  // MARK: Nested Types

  public enum Priority {
    case Background // Least important
    case Low
    case Normal
    case High
    case Main // Most important

    public var core: dispatch_queue_priority_t! {
      switch self {
        case .Main:       return nil
        case .High:       return DISPATCH_QUEUE_PRIORITY_HIGH
        case .Normal:     return DISPATCH_QUEUE_PRIORITY_DEFAULT
        case .Low:        return DISPATCH_QUEUE_PRIORITY_LOW
        case .Background: return DISPATCH_QUEUE_PRIORITY_BACKGROUND
      }
    }

    /// The built-in Queue associated with this Priority
    public var builtin: Queue {
      switch self {
        case .Main:       return gcd.main
        case .High:       return gcd.high
        case .Normal:     return gcd
        case .Low:        return gcd.low
        case .Background: return gcd.background
      }
    }
  }



  // MARK: Internal

  /// Initializes one of Apple's built-in queues.
  init (_ priority: Priority) {
    self.priority = priority
    isSerial = priority == .Main
    core = isSerial ? dispatch_get_main_queue() : dispatch_get_global_queue(priority.core, 0)
    isBuiltin = true
    _register()
  }

  /// Initializes a custom queue.
  init (_ serial: Bool, _ priority: Priority) {
    self.priority = priority
    isSerial = serial
    core = dispatch_queue_create(nil, serial ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT)
    isBuiltin = false
    _register()
  }

  

  // MARK: Private

  private func _register () {
    dispatch_queue_set_specific(core, &kQueueCurrentKey, getMutablePointer(self), nil)
  }
}

var kQueueCurrentKey = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Word(ObjectIdentifier(object).uintValue()))
}
