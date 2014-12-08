
/// An abstract class that performs jobs.
/// Thread and Queue subclass this.
public class Dispatcher {

  public class var current: Dispatcher! {
    return Queue.current ?? Thread.current
  }

  public var isCurrent: Bool {
    fatalError("Must override.")
  }

  public var isBlocked: Bool {
    return _isBlocked.value
  }

  /// If this Dispatcher is the current one, the callback is called immediately.
  /// Else, the callback is called synchronously on this Dispatcher.
  public func sync <Out> (job: Job<Void, Out>) -> Job<Void, Out> {
    isCurrent ? job.perform() : Dispatcher.current._block { self._perform(job, false) }
    return job
  }

  /// Calls the callback asynchronously on this Queue.
  /// The Thread you call this from will continue without waiting for your task to finish.
  public func async <Out> (job: Job<Void, Out>) -> Job<Void, Out> {
    _perform(job, true)
    return job
  }

  /// If this Dispatcher is the current Dispatcher, the callback is called immediately.
  /// Else, the callback is called asynchronously on this Dispatcher.
  public func csync <Out> (job: Job<Void, Out>) -> Job<Void, Out> {
    isCurrent ? job.perform() : _perform(job, true)
    return job
  }

  public func sync (task: Void -> Void) {
    let _ = sync(Job(task))
  }

  public func async (task: Void -> Void) {
    let _ = async(Job(task))
  }

  public func csync (task: Void -> Void) {
    let _ = csync(Job(task))
  }



  // MARK: Internal

  let _isBlocked = Lock(false)

  func _perform <In, Out> (job: Job<In, Out>, _ asynchronous: Bool) {
    fatalError("Must override.")
  }

  init () {}



  // MARK: Private

  private func _block (task: Void -> Void) {

    _isBlocked.lock { isBlocked in
      assert(!isBlocked, "blocking a blocked Dispatcher causes a deadlock")

      // Block the current Dispatcher
      isBlocked = true
    }

    task()

    // Unblock the current Dispatcher
    _isBlocked.value = false
  }
}
