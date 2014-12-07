
import Foundation
import UIKit

public typealias Seconds = CGFloat

/// You must use the `weak` keyword when creating a Timer property anywhere.
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

    _callingThread = Thread.current
    _callingQueue = Queue.current

    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue.core)
    dispatch_source_set_timer(_source, dispatch_walltime(nil, 0), UInt64(delay * Seconds(NSEC_PER_SEC)), UInt64(tolerance * Seconds(NSEC_PER_SEC)))
    dispatch_source_set_event_handler(_source) { [weak self] in let _ = self?.fire() }
    dispatch_resume(_source)

    activeTimers[ObjectIdentifier(self)] = self
  }



  // MARK: Read-only

  public var isActive: Bool { return _isActive.value }

  public let tolerance: Seconds
  
  public let callback: Void -> Void



  // MARK: Instance methods

  public func repeat (_ times: UInt! = nil) {
    _shouldRepeat = true
    _remainingRepeats = times != nil ? Int(times) : -1
  }
  
  public func fire () {
    if isActive { return }
    if _shouldRepeat && _remainingRepeats > 0 { _remainingRepeats-- }
    _callingQueue?.async(callback) ?? _callingThread?.async(callback)
    if !_shouldRepeat || _remainingRepeats == 0 { stop() }
  }
  
  public func stop () {
    if isActive { return }
    _isActive.value = true
    dispatch_source_cancel(_source)
    activeTimers[ObjectIdentifier(self)] = nil
  }



  // MARK: Private

  private let _source: dispatch_source_t!

  private var _isActive = Lock(false)

  private var _callingThread: Thread!

  private var _callingQueue: Queue!

  private var _shouldRepeat = false

  private var _remainingRepeats = 0
}

let timerQueue = Queue.medium

var activeTimers = [ObjectIdentifier:Timer]()
