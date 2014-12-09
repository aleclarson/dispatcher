
import Foundation
import UIKit

public typealias Seconds = CGFloat

/// You must use the `weak` keyword when creating a Timer property anywhere.
public class Timer {

  public init (_ delay: Seconds, _ callback: Void -> Void) {

    if delay <= 0 {
      callback()
      return
    }

    _self = self
    _callback = callback

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Seconds(NSEC_PER_SEC) * delay)), (Queue.current ?? Queue.main).core) {
      [weak self] in let _ = self?.fire()
    }
  }



  // MARK: Read-only

  public var isActive: Bool { return _isActive.value }



  // MARK: Instance methods

  public func repeat (_ times: UInt! = nil) {
    _shouldRepeat = true
    _remainingRepeats = times != nil ? Int(times) : -1
  }
  
  public func fire () {
    if !isActive { return }
    if _shouldRepeat && _remainingRepeats > 0 { _remainingRepeats-- }
    _callback()
    if !_shouldRepeat || _remainingRepeats == 0 { _stop() }
  }

  public func stop () {
    if isActive { _stop() }
  }



  // MARK: Private
  
  private let _callback: (Void -> Void)!

  private var _self: Timer!

  private var _isActive = Lock(true, serial: true)

  private var _shouldRepeat = false

  private var _remainingRepeats = 0

  private func _stop () {
    _isActive.value = false
    _self = nil
  }
}
