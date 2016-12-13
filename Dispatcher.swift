
import Dispatch

public let gcd = Dispatcher()

public class Dispatcher : DispatcherQueue {

  public var current: DispatcherQueue? {
    guard let unsafeRawPoiner = DispatchQueue.getSpecific(key: kCurrentQueue) else {
      return nil
    }

    return Unmanaged<DispatcherQueue>.fromOpaque(unsafeRawPoiner).takeUnretainedValue()
  }

  public let main = DispatcherQueue(queue: DispatchQueue.main)

  public let high = DispatcherQueue(qos: .userInitiated)

  public let low = DispatcherQueue(qos: .utility)

  public let background = DispatcherQueue(qos: .background)

  public func serial () -> DispatcherQueue {
    return DispatcherQueue(concurrent: false)
  }

  public func concurrent () -> DispatcherQueue {
    return DispatcherQueue(concurrent: true)
  }

  init () { super.init(qos: .default) }
}
