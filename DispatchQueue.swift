
import Foundation

public typealias Queue = DispatchQueue

public class DispatchQueue {

  // MARK: Public
  
  public let isConcurrent = false

  public var isCurrent: Bool { return dispatch_get_specific(&kCurrentQueue) == getMutablePointer(self) }

  public func async (callback: Void -> Void) {
    updatePreviousQueue()
    dispatch_async(dispatch_queue) { callback() }
  }
  
  public func sync (callback: Void -> Void) {
    updatePreviousQueue()
    _sync(callback)
  }

  public func async <T> (callback: T -> Void) -> T -> Void {
    return { [weak self] value in
      if self == nil { return }
      self!.async { callback(value) }
    }
  }

  public func sync <T> (callback: T -> Void) -> T -> Void {
    return { [weak self] value in
      if self == nil { return }
      self!.sync { callback(value) }
    }
  }

  public func async (callback: @autoclosure () -> Void) {
    async { callback() }
  }

  public func sync (callback: @autoclosure () -> Void) {
    sync { callback() }
  }

  public func suspend () {
    dispatch_suspend(self.dispatch_queue)
  }

  public func resume () {
    dispatch_resume(self.dispatch_queue)
  }

  public func barrier () {
    if !isConcurrent { return }
  }

  public let dispatch_queue: dispatch_queue_t



  // MARK: Internal

  var pauseGroup: DispatchGroup!

  init (_ queue: dispatch_queue_t) {
    dispatch_queue = queue
    updateCurrentQueue()
  }
  
  init (_ priority: dispatch_queue_priority_t) {
    isConcurrent = true
    dispatch_queue = dispatch_get_global_queue(priority, 0)
    updateCurrentQueue()
  }
  
  init (_ concurrent: Bool) {
    isConcurrent = concurrent
    dispatch_queue = dispatch_queue_create(nil, isConcurrent ? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL)
    updateCurrentQueue()
  }

  func updateCurrentQueue () {
    dispatch_queue_set_specific(dispatch_queue, &kCurrentQueue, getMutablePointer(self), nil)
  }

  func updatePreviousQueue () {
    dispatch_queue_set_specific(dispatch_queue, &kPreviousQueue, getMutablePointer(gcd.current), nil)
  }

  func _sync (callback: Void -> Void) {
    if isCurrent { callback(); return } // prevent deadlocks!
    dispatch_sync(dispatch_queue) { callback() }
  }
}

var kCurrentQueue = 0

var kPreviousQueue = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Word(ObjectIdentifier(object).uintValue()))
}
