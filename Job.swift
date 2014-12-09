
/// A Job releases itself after performing its task once.
public class Job <In, Out> : _Job {

  // MARK: Methods

  /// Perform a synchronous Job after this Job is completed.
  public func sync <NextOut> (task: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>.sync(task))
  }

  /// Perform a synchronous Job on the given Dispatcher after this Job is completed.
  public func sync <NextOut> (dispatcher: Dispatcher, _ task: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>.sync {
      arg in
      var out: NextOut!
      dispatcher.sync {
        out = task(arg)
      }
      return out
    })
  }

  /// Perform an asynchronous Job after this Job is completed.
  public func async <NextOut> (task: (Out, NextOut -> Void) -> Void) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>.async(task))
  }

  /// Perform an asynchronous Job on the given Dispatcher after this Job is completed.
  public func async <NextOut> (dispatcher: Dispatcher, _ task: (Out, NextOut -> Void) -> Void) -> Job<Out, NextOut> {
    return async {
      arg, done in
      dispatcher.async {
        task(arg, done)
      }
    }
  }



  // MARK: Constructors

  /// A synchronous Job must return a result upon completion.
  public class func sync (task: In -> Out) -> Job<In, Out> {
    return async { $1(task($0)) }
  }

  /// An asynchronous Job must call its callback with a result upon completion.
  public class func async (task: (In, Out -> Void) -> Void) -> Job<In, Out> {
    return Job(task)
  }



  // MARK: Private

  private let _task: (In, Out -> Void) -> Void

  private var _self: Job! // retain cycle to stay alive

  private init (_ task: (In, Out -> Void) -> Void) {
    _task = task
    super.init()
    _self = self
  }

  private override func _perform (arg: Any) {
    _task(arg as In, _finish)
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
      _next.value = unsafeBitCast(job, _Job.self)
      job._prev.value = unsafeBitCast(self, _Job.self)
    }

    return job
  }
}

public class _Job {

  /// Performs this Job's task immediately.
  /// If this Job is dependent on another Job, that Job will be performed first.
  public func perform () {
    if let prev = _prev.value {
      if let result = prev._result.value {
        _perform(result)
      } else {
        prev.perform()
      }
      _prev.value = nil
    } else {
      _perform(())
    }
  }



  // MARK: Private

  private let _result = Lock<Any>(serial: true)

  private let _next = Lock<_Job>(serial: true) // job depends on you

  private let _prev = Lock<_Job>(serial: true) // job you depend on

  private func _perform (arg: Any) {
    fatalError("Must override.")
  }
}

public typealias JobVoid = Job<Void,Void>

extension Thread {

  /// Allows Threads to perform Jobs
  class __Job : NSObject {

    init (_ job: _Job) {
      self.job = job
    }

    let job: _Job

    func perform () {
      job.perform()
    }
  }
}
