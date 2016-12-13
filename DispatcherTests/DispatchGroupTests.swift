
import UIKit
import XCTest
import Dispatcher

class DispatchGroupTests: XCTestCase {

  var group: DispatcherGroup!

  override func tearDown() {
    group = nil
    super.tearDown()
  }

  func testDispatchGroup () {
    let expectation = self.expectation(description: "")

    group = DispatcherGroup()

    group++

    group.done(expectation.fulfill)

    group--

    waitForExpectations(timeout: 1) { XCTAssertNil($0) }
  }

  func testThreadSafety () {
    let expectation = self.expectation(description: "")

    group = DispatcherGroup(2)

    gcd.async {
      self.group--
      gcd.main.sync {
        self.group--
      }
    }

    group.done(expectation.fulfill)

    waitForExpectations(timeout: 1) { XCTAssertNil($0) }
  }
}
