
import Foundation

public typealias Queue = DispatchQueue

public class DispatchQueue {

  // MARK: Public
  
  public let isConcurrent: Bool

  public var isCurrent: Bool { return dispatch_get_specific(&kCurrentQueue) == getMutablePointer(self) }

  public func async (callback: Void -> Void) {
    dispatch_async(dispatch_queue) { callback() }
  }
  
  public func sync (callback: Void -> Void) {
    if isCurrent { callback(); return } // prevent deadlocks!
    dispatch_sync(dispatch_queue) { callback() }
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

  public let dispatch_queue: dispatch_queue_t



  // MARK: Internal

  init (_ queue: dispatch_queue_t) {
    isConcurrent = false
    dispatch_queue = queue
    remember()
  }
  
  init (_ priority: dispatch_queue_priority_t) {
    isConcurrent = true
    dispatch_queue = dispatch_get_global_queue(priority, 0)
    remember()
  }
  
  init (_ concurrent: Bool) {
    isConcurrent = concurrent
    dispatch_queue = dispatch_queue_create(nil, isConcurrent ? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL)
    remember()
  }

  func remember () {
    dispatch_queue_set_specific(dispatch_queue, &kCurrentQueue, getMutablePointer(self), nil)
  }
}

var kCurrentQueue = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Int(ObjectIdentifier(object).uintValue))
}
