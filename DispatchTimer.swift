
import Foundation
import UIKit

public typealias Timer = DispatcherTimer

open class DispatcherTimer {

  public convenience init (_ delay: CGFloat, _ callback: @escaping (Void) -> Void) {
    self.init(delay, 0, callback)
  }

  public init (_ delay: CGFloat, _ tolerance: CGFloat, _ callback: @escaping (Void) -> Void) {
    self.callback = callback
    self.tolerance = tolerance

    if delay == 0 {
      callback()
      return
    }

    self.callbackQueue = gcd.current
    self.timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: queue.dispatch_queue)
    
    if !gcd.main.isCurrent {
      if let dispatch_queue = gcd.current?.dispatch_queue {
        queue.dispatch_queue.setTarget(queue: dispatch_queue)
      }
    }
    
    let delay_ns = delay * CGFloat(NSEC_PER_SEC)
    let time = DispatchTime.now() + Double(Int64(delay_ns)) / Double(NSEC_PER_SEC)

    let interval = DispatchTimeInterval.nanoseconds(Int(delay_ns))
    let leeway = DispatchTimeInterval.nanoseconds(Int(UInt64(tolerance * CGFloat(NSEC_PER_SEC))))

    timer?.scheduleRepeating(deadline: time, interval: interval, leeway: leeway)
    timer?.setEventHandler { [weak self] in let _ = self?.fire() }
    timer?.resume()
  }

  // MARK: Read-only

  open let tolerance: CGFloat
  
  open let callback: (Void) -> Void

  // MARK: Instance methods

  open func doRepeat (_ times: UInt! = nil) {
    isRepeating = true
    repeatsLeft = times != nil ? Int(times) : -1
  }

  open func autorelease () {
    isAutoReleased = true
    autoReleasedTimers[ObjectIdentifier(self)] = self
  }
  
  open func fire () {
    if OSAtomicAnd32OrigBarrier(1, &invalidated) == 1 { return }
    callbackQueue?.sync(callback)
    if isRepeating && repeatsLeft > 0 {
      repeatsLeft -= 1
    }
    if !isRepeating || repeatsLeft == 0 { stop() }
  }
  
  open func stop () {
    if OSAtomicTestAndSetBarrier(7, &invalidated) { return }
    queue.sync({self.timer?.cancel()})
    if isAutoReleased { autoReleasedTimers[ObjectIdentifier(self)] = nil }
  }

  // MARK: Internal

  var timer: DispatchSourceTimer?

  let queue: DispatcherQueue = gcd.serial()

  var callbackQueue: DispatcherQueue?

  var invalidated: UInt32 = 0

  var isAutoReleased = false

  var isRepeating = false

  var repeatsLeft = 0

  deinit {
    if !isAutoReleased { stop() }
  }
}

var autoReleasedTimers = [ObjectIdentifier:Timer]()
