
/// A Job releases itself after performing its task once.
public class Job <In, Out> : _Job {

  // MARK: Methods

  /// 1. Wait until this Job finishes.
  ///
  /// 2. Perform the given synchronous task.
  ///
  public func sync <NextOut> (task: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>.sync(task)) as Job<Out, NextOut>
  }

  /// 1. Wait until this Job finishes.
  ///
  /// 2. Asynchronously jump to the given Dispatcher, unless already on it.
  ///
  /// 3. Perform the given synchronous task.
  ///
  public func sync <NextOut> (dispatcher: Dispatcher, _ task: Out -> NextOut) -> Job<Out, NextOut> {
    return async {
      arg, done in
      dispatcher.csync {
        done(task(arg))
      }
    }
  }

  /// 1. Wait until this Job finishes.
  ///
  /// 2. Perform the given asynchronous task.
  ///
  public func async <NextOut> (task: (Out, NextOut -> Void) -> Void) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>.async(task)) as Job<Out, NextOut>
  }

  /// 1. Wait until this Job finishes.
  ///
  /// 2. Asynchronously jump to the given Dispatcher, even if already on it.
  ///
  /// 3. Perform the given asynchronous task.
  ///
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

  private init (_ task: (In, Out -> Void) -> Void) {
    super.init({
      arg, done in
      task(arg as In) {
        done($0 as Out)
      }
    })
  }
}

public class _Job {

  /// 1. Perform the Job this Job depends on, if one exists.
  ///
  /// 2. Perform this Job's task.
  ///
  public func perform () {
    if let prev = _prev.value {
      _prev.value = nil
      if let result = prev._result.value {
        _start(result)
      } else {
        return prev.perform()
      }
    } else {
      _start(())
    }
  }



  // MARK: Private

  private typealias Task = (Any, Any -> Void) -> Void

  private let _task: Task

  private var _self: _Job! // retain cycle to stay alive

  private init (_ task: Task) {
    _task = task
    _self = self
  }

  private let _result = Lock<Any>(serial: true)

  private let _next = Lock<_Job>(serial: true) // job depends on you

  private let _prev = Lock<_Job>(serial: true) // job you depend on

  private func _start (arg: Any) {
    _task(arg, _finish)
  }

  private func _finish (result: Any) {

    _result.value = result

    _next.write { job in
      if job == nil { return }
      job._start(result)
      job = nil
    }

    _self = nil
  }

  private func _next (job: _Job) -> _Job {

    // Perform the next Job immediately if this Job is already finished.
    if let result = _result.value { job._start(result) }

    // Else store the next Job until this Job finishes.
    else {
      _next.value = job
      job._prev.value = self
    }

    return job
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
