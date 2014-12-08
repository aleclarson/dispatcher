
public typealias AnyJob = Job<Any,Any>

/// A Job releases itself after performing its task once.
public class Job <In, Out> {

  /// A bridge closure is called when a Job finishes.
  /// The `async`, `sync`, and `barrier` methods of Queue/Thread work perfect here.
  public typealias Bridge = (Void -> Void) -> Void

  // MARK: Methods

  /// Performs this Job's task immediately.
  /// If this Job is dependent on another Job, that Job will be performed first.
  public func perform () {
    if let prev = _prev.value {
      if let result = prev._result.value {
        _perform(result as In)
      } else {
        prev.perform()
      }
      _prev.value = nil
    } else {
      _perform(() as In)
    }
  }

  /// Creates a Job that performs your task when this Job finishes.
  /// The task is performed on the current Dispatcher.
  public func next <NextOut> (task: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>(task))
  }

  /// Creates a Job that performs your task when this Job finishes.
  /// The task is performed inside of the passed bridge closure.
  /// Try passing `Queue.high.async` for example.
  public func next <NextOut> (bridge: Bridge, _ task: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut> {
      arg, done in bridge { done(task(arg)) }
    })
  }



  // MARK: Constructor

  public convenience init (_ task: In -> Out) {
    self.init({ arg, done in done(task(arg))  })
  }



  // MARK: Private

  private typealias Task = (In, Out -> Void) -> Void

  private let _task: Task

  private var _self: Job! // retain cycle to stay alive

  private let _result = Lock<Out>()

  private let _next = Lock<AnyJob>() // job depends on you

  private let _prev = Lock<AnyJob>() // job you depend on

  private init (_ work: Task) {
    _task = work
    _self = self
  }

  private func _perform (args: In) {
    _task(args, _finish)
  }

  private func _finish (result: Out) {

    _result.value = result

    _next.lock { job in
      if job == nil { return }
      job._perform(result)
      job = nil
    }

    _self = nil
  }

  private func _next <NextOut> (job: Job<Out,NextOut>) -> Job<Out,NextOut> {

    // Perform the next Job immediately if this Job is already finished.
    if let result = _result.value { job._perform(result) }

    // Else store the next Job until this Job finishes.
    else {
      _next.value = unsafeBitCast(job, AnyJob.self)
      job._prev.value = unsafeBitCast(self, AnyJob.self)
    }

    return job
  }
}

extension Thread {

  /// Allows Threads to perform Jobs
  class __Job : NSObject {

    init (_ job: AnyJob) {
      self.job = job
    }

    let job: AnyJob

    func perform () {
      job.perform()
    }
  }
}
