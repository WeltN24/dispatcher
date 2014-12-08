
import UIKit
import XCTest
import Dispatcher

class WorkTests: XCTestCase {

  var work: Work!

  override func tearDown() {
    work = nil
    super.tearDown()
  }

  func testWork () {
    let expectation = expectationWithDescription(nil)

    work = Work()

    work++

    work.done(expectation.fulfill)

    work--

    waitForExpectationsWithTimeout(1) { XCTAssertNil($0) }
  }

  func testThreadSafety () {
    let expectation = expectationWithDescription(nil)

    work = Work(2)

    Queue.medium.async {
      self.work--
      Queue.main.async {
        self.work--
      }
    }

    work.done(expectation.fulfill)

    waitForExpectationsWithTimeout(1) { XCTAssertNil($0) }
  }
}