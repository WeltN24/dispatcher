
import UIKit
import XCTest
import Dispatcher

class DispatchTimerTests: XCTestCase {

  var timer: DispatcherTimer!
  var calls = 0
  var view: UIView!

  override func tearDown() {
    timer = nil
    calls = 0
    super.tearDown()
  }

  func testDispatchTimer () {
    let expectation = self.expectation(description: "")

    timer = DispatcherTimer(1, expectation.fulfill)

    waitForExpectations(timeout: 1.1, handler: nil)
  }

  func testCallbackQueue () {
    let e = expectation(description: "")
    
    gcd.async {
      self.timer = DispatcherTimer(0.1) {
        XCTAssert(gcd.isCurrent)
        e.fulfill()
      }
    }

    waitForExpectations(timeout: 0.3, handler: nil)
  }

  func testFire () {
  
    timer = DispatcherTimer(1, {self.calls += 1})

    timer.fire()

    timer.fire() // Should not do anything.

    XCTAssert(calls == 1)
  }

  func testFiniteRepeatingTimer () {
    let expectation = self.expectation(description: "")

    timer = DispatcherTimer(0.25) {
      self.calls += 1
      if self.calls == 2 {
        expectation.fulfill()
      }
    }

    timer.doRepeat(2)

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testInfiniteRepeatingTimer () {
    let expectation = self.expectation(description: "")

    timer = DispatcherTimer(0.1) {
      self.calls += 1
      if self.calls == 5 {
        expectation.fulfill()
      }
    }

    timer.doRepeat()

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testAutoClosureTimer () {
    let expectation = self.expectation(description: "")

    timer = DispatcherTimer(0.1, {expectation.fulfill()})

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testAutoReleasedTimer () {
    let expectation = self.expectation(description: "")

    DispatcherTimer(0.5, {expectation.fulfill()}).autorelease()

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testUnretainedTimer () {
    let _ = DispatcherTimer(0.1, {self.calls += 1})
    timer = DispatcherTimer(0.2, {XCTAssert(self.calls == 0)})
  }

  func testThreadSafety () {
    let expectation = self.expectation(description: "")

    gcd.async {
      self.timer = Timer(0.5, gcd.main.sync({expectation.fulfill()}))
    }

    waitForExpectations(timeout: 1, handler: nil)
  }
}
