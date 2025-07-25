import Foundation
import XCTest

@testable import SwiftRohan

/// Test Either
final class EitherTests: XCTestCase {
  func test_flip() {
    let a = Either<Bool, Int>.Left(true)
    let b = Either<Bool, Int>.Right(1)

    XCTAssert(a.flip() == Either<Int, Bool>.Right(true))
    XCTAssert(b.flip() == Either<Int, Bool>.Left(1))
  }

  func test_map_either() {
    let a = Either<Bool, Int>.Left(true)
    let b = Either<Bool, Int>.Right(1)

    XCTAssert(a.map_either({ $0 ? -1 : 1 }, { $0 < 0 }) == Either<Int, Bool>.Left(-1))
    XCTAssert(b.map_either({ $0 ? -1 : 1 }, { $0 < 0 }) == Either<Int, Bool>.Right(false))
  }

  func test_map() {
    let a = Either<Int, Int>.Left(1)
    let b = Either<Int, Int>.Right(4)

    XCTAssert(a.map { $0 + 1 } == Either<Int, Int>.Left(2))
    XCTAssert(b.map { $0 + 1 } == Either<Int, Int>.Right(5))
  }

  func test_unwrap() {
    let a = Either<Int, Int>.Left(1)
    let b = Either<Int, Int>.Right(4)

    XCTAssert(a.unwrap() == 1)
    XCTAssert(b.unwrap() == 4)
  }

  func test_left() {
    let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.left() == 1)
    XCTAssert(b.left() == nil)
  }

  func test_right() {
    let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.right() == nil)
    XCTAssert(b.right() == false)
  }

  func test_is_left() {
    let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.is_left() == true)
    XCTAssert(b.is_left() == false)
  }

  func test_is_right() {
    let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.is_right() == false)
    XCTAssert(b.is_right() == true)
  }

  func test_map_left() {
    let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.map_left { $0 + 1 } == Either<Int, Bool>.Left(2))
    XCTAssert(b.map_left { $0 + 1 } == Either<Int, Bool>.Right(false))
  }

  func test_map_right() {
    let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.map_right { $0 == false } == Either<Int, Bool>.Left(1))
    XCTAssert(b.map_right { $0 == false } == Either<Int, Bool>.Right(true))
  }

  func test_unwrap_left() {
    let a = Either<Int, Bool>.Left(1)
    //        let b = Either<Int, Bool>.Right(false)

    XCTAssert(a.unwrap_left() == 1)
    //        XCTAssertThrowsError(b.unwrap_left())
  }

  func test_unwrap_right() {
    //        let a = Either<Int, Bool>.Left(1)
    let b = Either<Int, Bool>.Right(false)

    //        XCTAssertThrowsError(a.unwrap_left())
    XCTAssert(b.unwrap_right() == false)
  }
}
