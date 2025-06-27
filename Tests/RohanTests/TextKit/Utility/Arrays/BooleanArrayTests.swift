// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct BooleanArrayTests {

  @Test
  func empty() {
    let booleanArray = BooleanArray()
    #expect(booleanArray.count == 0)
    #expect(booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 0)
    #expect(booleanArray.asBitArray == [])
  }

  @Test
  func subscripting() {
    let booleanArray = BooleanArray([false, true, false, true])

    #expect(booleanArray[0] == false)
    #expect(booleanArray[1] == true)
    #expect(booleanArray[2] == false)
    #expect(booleanArray[3] == true)
  }

  @Test
  func insert() {
    var booleanArray = BooleanArray()

    // insert true
    booleanArray.insert(true, at: 0)
    #expect(booleanArray.count == 1)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 1)
    #expect(booleanArray.asBitArray == [true])

    // insert false
    booleanArray.insert(false, at: 1)
    #expect(booleanArray.count == 2)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 1)
    #expect(booleanArray.asBitArray == [true, false])

    // insert empty
    booleanArray.insert(contentsOf: [], at: 0)
    #expect(booleanArray.count == 2)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 1)
    #expect(booleanArray.asBitArray == [true, false])

    // insert [true, false]
    booleanArray.insert(contentsOf: [true, false], at: 0)
    #expect(booleanArray.count == 4)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 2)
    #expect(booleanArray.asBitArray == [true, false, true, false])
  }

  @Test
  func remove() {
    var booleanArray = BooleanArray([false, true, false, true, true])

    // remove at index 4
    booleanArray.remove(at: 4)
    #expect(booleanArray.count == 4)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 2)
    #expect(booleanArray.asBitArray == [false, true, false, true])

    // remove at index 0
    booleanArray.remove(at: 0)
    #expect(booleanArray.count == 3)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 2)
    #expect(booleanArray.asBitArray == [true, false, true])

    // remove range [0,2)
    booleanArray.removeSubrange(0..<2)
    #expect(booleanArray.count == 1)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 1)
    #expect(booleanArray.asBitArray == [true])

    // remove all
    booleanArray.removeAll()
    #expect(booleanArray.count == 0)
    #expect(booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 0)
    #expect(booleanArray.asBitArray == [])
  }

  @Test
  func replace() {
    var booleanArray = BooleanArray([false, true, false, true])

    // replace range [1,3) with [false, true]
    booleanArray.replaceSubrange(1..<3, with: [false, true])
    #expect(booleanArray.count == 4)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 2)
    #expect(booleanArray.asBitArray == [false, false, true, true])
  }

  @Test
  func setValue() {
    var booleanArray = BooleanArray([false, true])
    // set value
    booleanArray[0] = true
    #expect(booleanArray.count == 2)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 2)
    #expect(booleanArray.asBitArray == [true, true])

    // set value again
    booleanArray[1] = false
    #expect(booleanArray.count == 2)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 1)
    #expect(booleanArray.asBitArray == [true, false])

    // set value again
    booleanArray[1] = false
    #expect(booleanArray.count == 2)
    #expect(!booleanArray.isEmpty)
    #expect(booleanArray.trueCount == 1)
    #expect(booleanArray.asBitArray == [true, false])
  }
}
