
import CoreGraphics
import Dispatch

public typealias Group = DispatcherGroup

open class DispatcherGroup {

  public init (_ tasks: Int = 0) {
    for _ in 0..<tasks { ++self }
  }

  open fileprivate(set) var tasks = 0

  open let dispatch_group = DispatchGroup()
  
  open func done (_ callback: @escaping (Void) -> Void) {
    guard let current = gcd.current else {
      return
    }

    dispatch_group.notify(queue: current.dispatch_queue, execute: callback)
  }

  open func wait (_ delay: CGFloat, _ callback: (Void) -> Void) {
    let _ = dispatch_group.wait(timeout: DispatchTime.now() + Double(Int64(delay * CGFloat(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
  }

  deinit { assert(tasks == 0, "A DispatchGroup cannot be deallocated when tasks is greater than zero!") }
}

public prefix func ++ (group: DispatcherGroup) {
  objc_sync_enter(group)
  group.tasks += 1
  group.dispatch_group.enter()
  objc_sync_exit(group)
}

public prefix func -- (group: DispatcherGroup) {
  objc_sync_enter(group)
  group.tasks -= 1
  group.dispatch_group.leave()
  objc_sync_exit(group)
}

public postfix func ++ (group: DispatcherGroup) {
  ++group
}

public postfix func -- (group: DispatcherGroup) {
  --group
}
