
/// An abstract superclass for Thread and Queue.
public class Dispatcher {

  public class var current: Dispatcher! {
    return Queue.current ?? Thread.current
  }

  public var isCurrent: Bool {
    fatalError("Must override.")
  }

  public var isBlocked: Bool {
    return _isBlocked.get
  }

  /// If this Dispatcher is the current one, the callback is called immediately.
  /// Else, the callback is called synchronously on this Dispatcher.
  public func sync <Out> (closure: Void -> Out) -> Job<Void, Out> {
    let job = Job(closure)
    isCurrent ? job.perform() : Dispatcher.current._block { self._perform(job, false) }
    return job
  }

  /// Calls the callback asynchronously on this Queue.
  /// The Thread you call this from will continue without waiting for your closure to finish.
  public func async <Out> (closure: Void -> Out) -> Job<Void, Out> {
    let job = Job(closure)
    _perform(job, true)
    return job
  }

  /// If this Dispatcher is the current Dispatcher, the callback is called immediately.
  /// Else, the callback is called asynchronously on this Dispatcher.
  public func csync <Out> (closure: Void -> Out) -> Job<Void, Out> {
    let job = Job(closure)
    isCurrent ? job.perform() : _perform(job, true)
    return job
  }

  public func sync (closure: Void -> Void) {
    let _: Job<Void, Void> = sync(closure)
  }

  public func async (closure: Void -> Void) {
    let _: Job<Void, Void> = async(closure)
  }

  public func csync (closure: Void -> Void) {
    let _: Job<Void, Void> = csync(closure)
  }



  // MARK: Internal

  let _isBlocked = Lock(false)

  func _perform <In, Out> (job: Job<In, Out>, _ asynchronous: Bool) {
    fatalError("Must override.")
  }

  init () {}



  // MARK: Private

  private func _block (closure: Void -> Void) {

    let isBlocked = Dispatcher.current._isBlocked

    isBlocked.set { isBlocked in
      assert(!isBlocked, "blocking a blocked Dispatcher causes a deadlock")

      // Block the current Dispatcher
      isBlocked = true
    }

    closure()

    // Unblock the current Dispatcher
    isBlocked.set(false)
  }
}
