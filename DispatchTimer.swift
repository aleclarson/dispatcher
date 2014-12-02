
import Foundation
import UIKit

public typealias Timer = DispatchTimer

public typealias Seconds = CGFloat

public class DispatchTimer {

  public convenience init (_ delay: Seconds, _ callback: @autoclosure () -> Void) {
    self.init(delay, { callback() })
  }
  
  public convenience init (_ delay: Seconds, _ callback: Void -> Void) {
    self.init(delay, 0, callback)
  }

  public init (_ delay: Seconds, _ tolerance: Seconds, _ callback: Void -> Void) {
    self.callback = callback
    self.tolerance = tolerance

    if delay == 0 {
      callback()
      return
    }

    _callbackQueue = gcd.current
    _queue = gcd.high
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue.wrapped)
    let delay_ns = delay * Seconds(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay_ns))
    dispatch_source_set_timer(_timer, time, UInt64(delay_ns), UInt64(tolerance * Seconds(NSEC_PER_SEC)))
    dispatch_source_set_event_handler(_timer) { [weak self] in let _ = self?.fire() }
    dispatch_resume(_timer)
  }



  // MARK: Read-only

  public let tolerance: Seconds
  
  public let callback: Void -> Void



  // MARK: Instance methods

  public func repeat (_ times: UInt! = nil) {
    _shouldRepeat = true
    _remainingRepeats = times != nil ? Int(times) : -1
  }

  public func autorelease () {
    if _invalidated { return }
    _releasesItself = true
    autoReleasedTimers[ObjectIdentifier(self)] = self
  }
  
  public func fire () {
    if _invalidated { return }
    _callbackQueue.sync(callback)
    if _shouldRepeat && _remainingRepeats > 0 { _remainingRepeats-- }
    if !_shouldRepeat || _remainingRepeats == 0 { stop() }
  }
  
  public func stop () {
    if _invalidated { return }
    _invalidated = true
    _queue.sync { dispatch_source_cancel(self._timer) }
    if _releasesItself { autoReleasedTimers[ObjectIdentifier(self)] = nil }
  }



  // MARK: Internal

  let _timer: dispatch_source_t!
  let _queue: DispatchQueue!
  var _callbackQueue: DispatchQueue!

  var _releasesItself = false

  var _shouldRepeat = false
  var _remainingRepeats = 0

  var __invalidated = false
  var _invalidated: Bool {
    get {
      return lock(self) { self.__invalidated }
    }
    set {
      lock(self) { self.__invalidated = newValue }
    }
  }


  deinit {
    if !_releasesItself { stop() }
  }
}

var autoReleasedTimers = [ObjectIdentifier:Timer]()

func lock <T> (obj: AnyObject, block: Void -> T) -> T {
  objc_sync_enter(obj)
  let value = block()
  objc_sync_exit(obj)
  return value
}
