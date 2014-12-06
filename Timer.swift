
import Foundation
import UIKit

public typealias Seconds = CGFloat

public class Timer {
  
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

    _callingThread = currentThread
    _callingQueue = gcd.current
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue.wrapped)
    dispatch_source_set_timer(_source, dispatch_walltime(nil, 0), UInt64(delay * Seconds(NSEC_PER_SEC)), UInt64(tolerance * Seconds(NSEC_PER_SEC)))
    dispatch_source_set_event_handler(_source) { [weak self] in let _ = self?.fire() }
    dispatch_resume(_source)

    activeTimers[ObjectIdentifier(self)] = self
  }



  // MARK: Read-only

  public let tolerance: Seconds
  
  public let callback: Void -> Void



  // MARK: Instance methods

  public func repeat (_ times: UInt! = nil) {
    _shouldRepeat = true
    _remainingRepeats = times != nil ? Int(times) : -1
  }
  
  public func fire () {
    if _invalidated { return }
    _callingThread.sync(callback)
    if _shouldRepeat && _remainingRepeats > 0 { _remainingRepeats-- }
    if !_shouldRepeat || _remainingRepeats == 0 { stop() }
  }
  
  public func stop () {
    if _invalidated { return }
    _invalidated = true
    dispatch_source_cancel(_source)
    activeTimers[ObjectIdentifier(self)] = nil
  }



  // MARK: Internal

  let _source: dispatch_source_t!
  var _callingThread: Thread!
  var _callingQueue: Queue!

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
}

let timerQueue = gcd

var activeTimers = [ObjectIdentifier:Timer]()

func lock <T> (obj: AnyObject, block: Void -> T) -> T {
  objc_sync_enter(obj)
  let value = block()
  objc_sync_exit(obj)
  return value
}
