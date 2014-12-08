
/// Synchronizes a value across Threads.
public class Lock<T> {

  public var get: T! {
    var value: T!
    _queue.sync { value = self._value }
    return value
  }

  public func set (newValue: T!) {
    _write { self._value = newValue }
  }

  /// Combines a read and write into a single transaction to save time.
  /// Keep your block as short as possible.
  public func set (block: (inout T!) -> Void) {
    _write { block(&self._value) }
  }

  /// If `serial` equals `true`, everything blocks everything.
  /// If `serial` equals `false`, writes block everything, but reads are concurrent.
  public init (_ defaultValue: T! = nil, _ serial: Bool = false) {
    _queue = (serial ? Queue.serial : Queue.concurrent)(Queue.current.priority)
    _write = serial ? _queue.sync : _queue.barrier
    _value = defaultValue
  }



  // MARK: Private

  private let _write: AnyJob.Wrapper

  private let _queue: Queue

  private var _value: T!
}
