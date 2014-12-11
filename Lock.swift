
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
  public func write (block: (inout T!) -> Void) -> T! {
    var value: T!
    _write { block(&self._value) }
    return value
  }

  public init (_ defaultValue: T! = nil, serial: Bool = false) {
    if !serial { _queue = Queue(false, Queue.current.priority) }
    _value = defaultValue
  }



  // MARK: Private

  private var _value: T!

  private let _queue: Queue!

  private func _write (block: Void -> Void) {
    _queue?.barrier(block) ?? _sync(block)
  }

  private func _read (block: Void -> Void) {
    _queue?.sync(block) ?? _sync(block)
  }

  private func _sync (block: Void -> Void) {
    objc_sync_enter(self); block(); objc_sync_exit(self)
  }
}
