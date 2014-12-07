
import Foundation

public class Thread {

  public var isCurrent: Bool {
    return core === NSThread.currentThread()
  }

  public var isMain: Bool {
    return core === NSThread.mainThread()
  }

  public class var current: Thread {
    return Thread.wrap(NSThread.currentThread())
  }

  public class var main: Thread {
    return Thread.wrap(NSThread.mainThread())
  }



  // MARK: Methods

  /// Pushes a block to be performed on this Thread.
  /// This function always returns after the passed block finishes executing.
  public func sync (block: Void -> Void) {
    isCurrent ? block() : perform(false, block)
  }

  /// Pushes a block to be performed on this Thread.
  /// This function typically returns before the passed block finishes executing.
  public func async (block: Void -> Void) {
    perform(true, block)
  }

  /// Pushes a block to be performed on this Thread.
  /// If `isCurrent` is `true`, the passed block is called with `sync()`.
  /// If `isCurrent` is `false`, the passed block is called with `async()`.
  public func csync (block: Void -> Void) {
    isCurrent ? block() : async(block)
  }

  /// Wraps an NSThread with a Thread and caches the result.
  /// If the NSThread has been wrapped earlier, the cached result is used.
  public class func wrap (thread: NSThread) -> Thread {
    let id = ObjectIdentifier(thread)

    if let thread = threadCache[id] {
      return thread
    }

    let thread = Thread(thread)
    threadCache[id] = thread
    return thread
  }



  // MARK: Private

  private let core: NSThread

  private init (_ thread: NSThread) {
    core = thread
  }

  private func perform (asynchronous: Bool, _ block: Void -> Void) {
    var task: Task!
    task = Task { block(); task = nil }
    core.callMethod("execute", target: task, asynchronous: asynchronous)
  }

  private class Task : NSObject {

    init (_ block: Void -> Void) {
      task = block
      super.init()
    }

    let task: Void -> Void

    @objc func execute () { task() }
  }
}

private var threadCache = [ObjectIdentifier:Thread]()
