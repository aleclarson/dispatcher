
import Foundation

/// Threads are serial by definition.
/// Queues manage their own Threads.
public class Thread : Dispatcher {

  // MARK: Properties

  public override var isCurrent: Bool { return core === NSThread.currentThread() }

  public var isMain: Bool { return core === NSThread.mainThread() }

  public let core: NSThread



  // MARK: Class Variables

  public override class var current: Thread {
    return Thread.wrap(NSThread.currentThread())
  }

  public class var main: Thread {
    return Thread.wrap(NSThread.mainThread())
  }



  // MARK: Class Methods

  /// Wraps an NSThread with a Thread and caches the result.
  /// If the NSThread has been wrapped earlier, the cached result is used.
  /// Avoid creating and wrapping your own NSThreads in favor of using a serial Queue.
  public class func wrap (thread: NSThread) -> Thread {
    let id = ObjectIdentifier(thread)

    if let thread = threadCache[id] {
      return thread
    }

    let thread = Thread(thread)
    threadCache[id] = thread
    return thread
  }



  // MARK: Internal

  override func _perform <In, Out> (job: Job<In, Out>, _ asynchronous: Bool) {
    core.callMethod("perform", target: __Job(unsafeBitCast(job, AnyJob.self)), asynchronous: asynchronous)
  }


  // MARK: Private

  private init (_ thread: NSThread) {
    core = thread
    super.init()
  }
}

private var threadCache = [ObjectIdentifier:Thread]()
