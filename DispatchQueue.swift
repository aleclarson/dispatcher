
import Foundation

public typealias Queue = DispatchQueue

public class DispatchQueue {

  // MARK: Public
  
  public let isConcurrent = false

  public var isCurrent: Bool { return dispatch_get_specific(&kCurrentQueue) == getMutablePointer(self) }

  /// Calls the callback asynchronously on this queue.
  public func async (callback: Void -> Void) {
    dispatch_async(wrapped) { callback() }
  }

  /// If this queue is the current queue, the callback is called immediately.
  /// Else, the callback is called synchronously on this queue.
  public func sync (callback: Void -> Void) {
    isCurrent ? callback() : dispatch_sync(wrapped, { callback() })
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

  /// If this queue is the current queue, the callback is called immediately.
  /// Else, the callback is called asynchronously on this queue.
  public func jump (callback: Void -> Void) {
    isCurrent ? callback() : async(callback)
  }

  public func suspend () {
    dispatch_suspend(self.wrapped)
  }

  public func resume () {
    dispatch_resume(self.wrapped)
  }

  public func barrier () {
    if !isConcurrent { return }
  }

  public class func wrap (wrapped: dispatch_queue_t!) -> DispatchQueue! {
    if wrapped == nil { return nil }
    let queue = dispatch_queue_get_specific(wrapped, &kCurrentQueue)
    if queue == nil { return DispatchQueue(wrapped) }
    return Unmanaged<DispatchQueue>.fromOpaque(COpaquePointer(queue)).takeUnretainedValue()
  }

  public let wrapped: dispatch_queue_t



  // MARK: Internal

  var pauseGroup: DispatchGroup!

  init (_ queue: dispatch_queue_t) {
    wrapped = queue
    updateCurrentQueue()
  }
  
  init (_ priority: dispatch_queue_priority_t) {
    isConcurrent = true
    wrapped = dispatch_get_global_queue(priority, 0)
    updateCurrentQueue()
  }
  
  init (_ concurrent: Bool) {
    isConcurrent = concurrent
    wrapped = dispatch_queue_create(nil, isConcurrent ? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL)
    updateCurrentQueue()
  }

  func updateCurrentQueue () {
    dispatch_queue_set_specific(wrapped, &kCurrentQueue, getMutablePointer(self), nil)
  }
}

var kCurrentQueue = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Word(ObjectIdentifier(object).uintValue()))
}
