
import Foundation

public class DispatchQueue {

  // MARK: Public
  
  public let isConcurrent = false

  public var isCurrent: Bool { return dispatch_get_specific(&kCurrentQueue) == getMutablePointer(self) }

  public func async (block: Void -> Void) { enqueue(dispatch_async, block) }
  
  public func sync (block: Void -> Void) { enqueue(dispatch_sync, block) }

  public let dispatch_queue: dispatch_queue_t



  // MARK: Internal

  init (_ queue: dispatch_queue_t) {
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
    dispatch_queue = dispatch_queue_create(NSUUID().UUIDString, isConcurrent ? DISPATCH_QUEUE_CONCURRENT : DISPATCH_QUEUE_SERIAL)
    remember()
  }
  
  func enqueue (dispatcher: (dispatch_queue_t, dispatch_block_t) -> Void, _ block: Void -> Void) {
    if isCurrent { return block() }
    dispatcher(dispatch_queue, block)
  }

  func remember () {
    dispatch_queue_set_specific(dispatch_queue, &kCurrentQueue, getMutablePointer(self), nil)
  }
}

var kCurrentQueue = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Word(ObjectIdentifier(object).uintValue()))
}
