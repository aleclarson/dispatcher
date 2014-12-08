
/// Synchronizes a value across Threads.
///
/// With a serial lock, each read or write transaction blocks all other transactions.
///
/// With a concurrent lock, each write transaction blocks all other transactions; while reads are non-blocking.

public class Lock <T> {

  /// The synchronized value
  public var value: T! {
    get {
      var value: T!
      _read { value = self._value }
      return value
    }
    set {
      _write { self._value = newValue }
    }
  }

  /// Locks the value for the duration of the passed block.
  /// This allows for both reading and writing in a single transaction.
  public func lock (block: (inout T!) -> Void) {
    _write { block(&self._value) }
  }

  public init (_ defaultValue: T! = nil, serial: Bool = false, priority: Queue.Priority = Queue.current.priority) {
    _queue = Queue(serial, priority)
    _value = defaultValue
  }



  // MARK: Private

  private let _queue: Queue

  private var _write: AnyJob.Bridge {
    return _queue.isSerial ? _queue.sync : _queue.barrier
  }

  private var _read: AnyJob.Bridge {
    return _queue.sync
  }

  private var _value: T!
}
