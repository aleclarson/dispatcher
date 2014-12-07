
import Foundation

/// Threads are serial by definition.
/// Queues manage their own Threads.
public class Thread {

  // MARK: Properties

  public var isBlocked: Bool { return _blocked.value }

  public var isCurrent: Bool { return core === NSThread.currentThread() }

  public var isMain: Bool { return core === NSThread.mainThread() }

  private let core: NSThread



  // MARK: Methods

  /// Pushes a closure to be performed on this Thread.
  /// This function always returns after the passed closure finishes executing.
  public func sync (closure: Void -> Void) {
    isCurrent ? closure() : blockCurrentQueueOrThread { Task(self, false, closure); return }
  }

  /// Pushes a closure to be performed on this Thread.
  /// This function typically returns before the passed closure finishes executing.
  public func async (closure: Void -> Void) {
    Task(self, true, closure)
  }

  /// Pushes a closure to be performed on this Thread.
  /// If `isCurrent` is `true`, the passed closure is called with `sync()`.
  /// If `isCurrent` is `false`, the passed closure is called with `async()`.
  public func csync (closure: Void -> Void) {
    isCurrent ? closure() : async(closure)
  }



  // MARK: Class Variables

  public class var current: Thread {
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

  let _blocked = Lock(false)


  // MARK: Private

  private init (_ thread: NSThread) {
    core = thread
  }

  /// A closure waiting to be executed on any Thread
  private class Task : NSObject {

    init (_ thread: Thread, _ asynchronous: Bool, _ closure: Void -> Void) {

      var task: Task! // retains `self` until `closure` is executed

      self.closure = {
        closure()
        task = nil
      }

      super.init()

      task = self

      thread.core.callMethod("execute", target: self, asynchronous: asynchronous)
    }

    let closure: Void -> Void

    var executed = false

    @objc func execute () {
      assert(!executed, "a task shouldn't execute more than once")
      executed = true
      closure()
    }

    deinit {
      assert(executed, "a task shouldn't deallocate before it finishes")
    }
  }
}

func blockCurrentQueueOrThread (closure: Void -> Void) {

  let blocked = Queue.current?._blocked ?? Thread.current._blocked

  blocked.write { blocked in
    assert(!blocked, "blocking a blocked queue or thread causes a deadlock")

    // Block the current queue/thread
    blocked = true
  }

  closure()

  // Unblock the current queue/thread
  blocked.value = false
}

private var threadCache = [ObjectIdentifier:Thread]()
