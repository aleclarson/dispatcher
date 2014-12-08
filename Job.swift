
public typealias AnyJob = Job<Any,Any>

func b () {
  Queue.high.async {}
}

/// A closure that runs on either a Thread or Queue.
/// A Job releases itself after performing its closure once.
public class Job <In, Out> {

  /// Wraps a Job's closure when performed.
  /// The `async`, `sync`, and `barrier` methods of Queue/Thread work perfect here.
  public typealias Wrapper = (Void -> Void) -> Job<Void, Void>

  // MARK: Methods

  /// Performs this Job's closure immediately.
  /// If this Job is dependent on another Job, that Job will be performed first.
  public func perform () {
    if let prev = _prev.get {
      if let result = prev._result.get {
        _perform(result as In)
      } else {
        prev.perform()
      }
      _prev.set(nil)
    } else {
      _perform(() as In)
    }
  }

  /// Creates a Job that performs your closure when this Job finishes.
  /// The closure is performed on the current Queue or Thread.
  public func next <NextOut> (closure: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut>(closure))
  }

  /// Creates a Job that performs your closure when this Job finishes.
  /// The closure is performed inside the passed wrapper.
  /// Try passing `Queue.high.async`.
  public func next <NextOut> (wrapper: Wrapper, _ closure: Out -> NextOut) -> Job<Out, NextOut> {
    return _next(Job<Out, NextOut> {
      arg, done in let _ = wrapper { done(closure(arg)) }
    })
  }



  // MARK: Constructor

  public convenience init (_ closure: In -> Out) {
    self.init({ arg, done in done(closure(arg))  })
  }



  // MARK: Destructor

  deinit {
    assert(_started.get, "a Job cannot deinit before it is started")
  }



  // MARK: Private

  private typealias Closure = (In, Out -> Void) -> Void

  private let _closure: Closure

  private var _started = Lock(false)

  private var _self: Job! // retain cycle to stay alive

  private let _result = Lock<Out>()

  private let _next = Lock<AnyJob>() // job depends on you

  private let _prev = Lock<AnyJob>() // job you depend on

  private init (_ closure: Closure) {
    _closure = closure
    _self = self
  }

  private func _perform (args: In) {
    _started.set {
      isPerformed in
      assert(!isPerformed, "a Job cannot be started more than once")
      isPerformed = true
    }
    _closure(args, _finish)
  }

  private func _finish (result: Out) {

    _result.set(result)

    _next.set { job in
      if job == nil { return }
      job._perform(result)
      job = nil
    }

    _self = nil
  }

  private func _next <NextOut> (job: Job<Out,NextOut>) -> Job<Out,NextOut> {

    // Perform the next Job immediately if this Job is already finished.
    if let result = _result.get { job._perform(result) }

    // Else store the next Job until this Job finishes.
    else {
      _next.set(unsafeBitCast(job, AnyJob.self))
      job._prev.set(unsafeBitCast(self, AnyJob.self))
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

    deinit {
      assert(job._started.get)
    }
  }
}
