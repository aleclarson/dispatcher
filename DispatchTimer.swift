
import Foundation
import UIKit

public typealias Timer = DispatchTimer

public class DispatchTimer {

  public convenience init (_ delay: CGFloat, _ callback: @autoclosure () -> Void) {
    self.init(delay, { callback() })
  }
  
  public convenience init (_ delay: CGFloat, _ callback: Void -> Void) {
    self.init(delay, 0, callback)
  }

  public init (_ delay: CGFloat, _ tolerance: CGFloat, _ callback: Void -> Void) {
    self.callback = callback
    self.tolerance = tolerance

    if delay == 0 {
      callback()
      return
    }

    callbackQueue = gcd.current
    queue = gcd.serial()
    if !gcd.main.isCurrent { dispatch_set_target_queue(queue.dispatch_queue, gcd.current.dispatch_queue) }
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue.dispatch_queue)
    let delay_ns = delay * CGFloat(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay_ns))
    dispatch_source_set_timer(timer, time, UInt64(delay_ns), UInt64(tolerance * CGFloat(NSEC_PER_SEC)))
    dispatch_source_set_event_handler(timer) { [weak self] in let _ = self?.fire() }
    dispatch_resume(timer)
  }



  // MARK: Read-only

  public let tolerance: CGFloat
  
  public let callback: Void -> Void



  // MARK: Instance methods

  public func repeat (_ times: UInt! = nil) {
    isRepeating = true
    repeatsLeft = times != nil ? Int(times) : -1
  }

  public func autorelease () {
    isAutoReleased = true
    autoReleasedTimers[ObjectIdentifier(self)] = self
  }
  
  public func fire () {
    if OSAtomicAnd32OrigBarrier(1, &invalidated) == 1 { return }
    callbackQueue.sync(callback)
    if isRepeating && repeatsLeft > 0 { repeatsLeft-- }
    if !isRepeating || repeatsLeft == 0 { stop() }
  }
  
  public func stop () {
    if OSAtomicTestAndSetBarrier(7, &invalidated) { return }
    queue.sync(dispatch_source_cancel(timer))
    if isAutoReleased { autoReleasedTimers[ObjectIdentifier(self)] = nil }
  }



  // MARK: Internal

  let timer: dispatch_source_t!

  let queue: DispatchQueue!

  var callbackQueue: DispatchQueue!

  var invalidated: UInt32 = 0

  var isAutoReleased = false

  var isRepeating = false

  var repeatsLeft = 0

  deinit {
    if !isAutoReleased { stop() }
  }
}

var autoReleasedTimers = [ObjectIdentifier:Timer]()
