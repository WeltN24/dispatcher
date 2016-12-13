
import Foundation

open class DispatcherQueue {

  // MARK: Public
  
  open let isConcurrent: Bool

  open var isCurrent: Bool {
    return DispatchQueue.getSpecific(key: kCurrentQueue) == getMutablePointer(self)
  }

  open func async (_ callback: @escaping (Void) -> Void) {
    dispatch_queue.async(execute: callback)
  }
  
  open func sync (_ callback: (Void) -> Void) {
    if isCurrent { callback(); return } // prevent deadlocks!
    dispatch_queue.sync(execute: callback)
  }

  open func async <T> (_ callback: @escaping (T) -> Void) -> (T) -> Void {
    return { [weak self] value in
      guard let strongSelf = self else { return }
      strongSelf.async { callback(value) }
    }
  }

  open func sync <T> (_ callback: @escaping (T) -> Void) -> (T) -> Void {
    return { [weak self] value in
      guard let strongSelf = self else { return }
      strongSelf.sync { callback(value) }
    }
  }

  open let dispatch_queue: DispatchQueue



  // MARK: Internal

  init (queue: DispatchQueue) {
    isConcurrent = false
    dispatch_queue = queue
    remember()
  }

  init (qos: DispatchQoS.QoSClass) {
    isConcurrent = true
    dispatch_queue = DispatchQueue.global(qos: qos)
    remember()
  }
  
  init (concurrent: Bool) {
    isConcurrent = concurrent
    
    // https://bugs.swift.org/browse/SR-1859
    if #available(iOS 10.0, *) {
      dispatch_queue = DispatchQueue(label: "", attributes: isConcurrent ? [DispatchQueue.Attributes.concurrent, DispatchQueue.Attributes.initiallyInactive] : [DispatchQueue.Attributes.initiallyInactive])
    } else {
      dispatch_queue = DispatchQueue(label: "", attributes: isConcurrent ? [DispatchQueue.Attributes.concurrent] : [])
    }
    remember()
  }

  func remember () {
    guard let mutablePointer = getMutablePointer(self) else {
      return
    }
    
    dispatch_queue.setSpecific(key: kCurrentQueue, value: mutablePointer)
  }
}

var kCurrentQueue = DispatchSpecificKey<UnsafeMutableRawPointer>()

func getMutablePointer (_ object: AnyObject) -> UnsafeMutableRawPointer? {
  return UnsafeMutableRawPointer(bitPattern: Int(bitPattern: ObjectIdentifier(object)))
}
