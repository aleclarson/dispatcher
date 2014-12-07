
/// Synchronizes a value across Threads (including Queues).
public class Lock<T> {

  public var value: T! {
    get {
      var value: T!
      _queue.sync { value = self._value }
      return value
    }
    set {
      _write { self._value = newValue }
    }
  }

  /// If `serial` equals `true`, everything blocks everything.
  /// If `serial` equals `false`, writes block everything, but reads are concurrent.
  public init (_ defaultValue: T! = nil, _ serial: Bool = false) {
    _queue = (serial ? Queue.serial : Queue.concurrent)(Queue.current.priority)
    _write = serial ? _queue.sync : _queue.barrier
    _value = defaultValue
  }

  private let _write: (Void -> Void) -> Void

  private let _queue: Queue

  private var _value: T!
}
