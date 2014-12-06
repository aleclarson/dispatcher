
import Foundation

public var currentThread: Thread {
  return Thread.wrap(NSThread.currentThread())
}

public var mainThread: Thread {
  return Thread.wrap(NSThread.mainThread())
}

public class Thread {

  public var isCurrent: Bool {
    return thread === NSThread.currentThread()
  }

  public var isMain: Bool {
    return thread === NSThread.mainThread()
  }

  /// Executes the given task synchronously,
  /// returning after the task is completed.
  public func sync (task: Void -> Void) {
    isCurrent ? task() : Task(task).schedule(self, false)
  }

  /// Executes the given task asynchronously,
  /// returning before the task is completed (usually).
  public func async (task: Void -> Void) {
    Task(task).schedule(self, true)
  }

  /// If this thread is the current thread, the given task
  /// is executed synchronously. Otherwise, it's executed asynchronously.
  public func csync (task: Void -> Void) {
    isCurrent ? task() : async(task)
  }

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

  private let thread: NSThread

  private var tasks = [ObjectIdentifier:Task]()

  private init (_ thread: NSThread) {
    self.thread = thread
  }

  private func retainTask (task: Task, isRetained: Bool) {
    let id = ObjectIdentifier(task)
    let newValue: Task! = isRetained ? task : nil
    lock(self) { self.tasks[id] = newValue }
  }

  private class Task : NSObject {

    init (_ task: Void -> Void) {
      self.task = task
      super.init()
    }

    let task: Void -> Void

    weak var thread: Thread!

    /// Adds this task to its assigned thread to be performed when possible.
    func schedule (thread: Thread, _ asynchronous: Bool) {
      self.thread = thread
      thread.retainTask(self, isRetained: true)
      thread.thread.callMethod("execute", target: self, asynchronous: asynchronous)
    }

    /// Executes the given task block immediately.
    @objc func execute () {
      task()
      thread?.retainTask(self, isRetained: false)
    }
  }
}

private var threadCache = [ObjectIdentifier:Thread]()
