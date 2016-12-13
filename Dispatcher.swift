
import Dispatch

public let gcd = Dispatcher()

public class Dispatcher : DispatcherQueue {

  public var current: DispatcherQueue? {
    guard let unsafeRawPoiner = DispatchQueue.getSpecific(key: kCurrentQueue) else {
      return nil
    }

    return Unmanaged<DispatcherQueue>.fromOpaque(unsafeRawPoiner).takeUnretainedValue()
  }

  public let main = DispatcherQueue(DispatchQueue.main)

  public let high = DispatcherQueue(.userInitiated)

  public let low = DispatcherQueue(.utility)

  public let background = DispatcherQueue(.background)

  public func serial () -> DispatcherQueue {
    return DispatcherQueue(false)
  }

  public func concurrent () -> DispatcherQueue {
    return DispatcherQueue(true)
  }

  init () { super.init(.default) }
}
