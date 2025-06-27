// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct BoolArrayTests {

  @Test
  func empty() {
    let boolArray = BoolArray()
    #expect(boolArray.count == 0)
    #expect(boolArray.isEmpty)
    #expect(boolArray.trueCount == 0)
    #expect(boolArray == [])
  }

  @Test
  func subscripting() {
    let boolArray: BoolArray = [false, true, false, true]

    // query
    #expect(boolArray[0] == false)
    #expect(boolArray[1] == true)
    #expect(boolArray[2] == false)
    #expect(boolArray[3] == true)

    // set
    var mutableBoolArray = boolArray
    mutableBoolArray[0] = true
    mutableBoolArray[1] = false
    mutableBoolArray[2] = true
    mutableBoolArray[3] = false
    #expect(mutableBoolArray.count == 4)
    #expect(!mutableBoolArray.isEmpty)
    #expect(mutableBoolArray.trueCount == 2)
    #expect(mutableBoolArray == [true, false, true, false])
  }

  @Test
  func insert() {
    var boolArray = BoolArray()

    // insert true
    boolArray.insert(true, at: 0)
    #expect(boolArray.count == 1)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 1)
    #expect(boolArray == [true])

    // insert false
    boolArray.insert(false, at: 1)
    #expect(boolArray.count == 2)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 1)
    #expect(boolArray == [true, false])

    // insert empty
    boolArray.insert(contentsOf: [], at: 0)
    #expect(boolArray.count == 2)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 1)
    #expect(boolArray == [true, false])

    // insert [true, false]
    boolArray.insert(contentsOf: [true, false], at: 0)
    #expect(boolArray.count == 4)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 2)
    #expect(boolArray == [true, false, true, false])
  }

  @Test
  func remove() {
    var boolArray: BoolArray = [false, true, false, true, true]

    // remove at index 4
    boolArray.remove(at: 4)
    #expect(boolArray.count == 4)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 2)
    #expect(boolArray == [false, true, false, true])

    // remove at index 0
    boolArray.remove(at: 0)
    #expect(boolArray.count == 3)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 2)
    #expect(boolArray == [true, false, true])

    // remove range [0,2)
    boolArray.removeSubrange(0..<2)
    #expect(boolArray.count == 1)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 1)
    #expect(boolArray == [true])

    // remove all
    boolArray.removeAll()
    #expect(boolArray.count == 0)
    #expect(boolArray.isEmpty)
    #expect(boolArray.trueCount == 0)
    #expect(boolArray == [])
  }

  @Test
  func replace() {
    var boolArray: BoolArray = [false, true, false, true]

    // replace range [1,3) with [false, true]
    boolArray.replaceSubrange(1..<3, with: [false, true])
    #expect(boolArray.count == 4)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 2)
    #expect(boolArray == [false, false, true, true])
  }

  @Test
  func setValue() {
    var boolArray: BoolArray = [false, true]
    // set value
    boolArray[0] = true
    #expect(boolArray.count == 2)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 2)
    #expect(boolArray == [true, true])

    // set value again
    boolArray[1] = false
    #expect(boolArray.count == 2)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 1)
    #expect(boolArray == [true, false])

    // set value again
    boolArray[1] = false
    #expect(boolArray.count == 2)
    #expect(!boolArray.isEmpty)
    #expect(boolArray.trueCount == 1)
    #expect(boolArray == [true, false])
  }

  @Test
  func trueIndex() {
    let boolArray: BoolArray = [false, true, false, false, false, true]

    // query true indices after
    #expect(boolArray.trueIndex(after: -1) == 1)
    #expect(boolArray.trueIndex(after: 0) == 1)
    #expect(boolArray.trueIndex(after: 1) == 5)
    #expect(boolArray.trueIndex(after: 2) == 5)
    #expect(boolArray.trueIndex(after: 3) == 5)
    #expect(boolArray.trueIndex(after: 4) == 5)
    #expect(boolArray.trueIndex(after: 5) == nil)
    #expect(boolArray.trueIndex(after: 6) == nil)
    #expect(boolArray.trueIndex(after: 7) == nil)

    // query true indices before
    #expect(boolArray.trueIndex(before: -1) == nil)
    #expect(boolArray.trueIndex(before: 0) == nil)
    #expect(boolArray.trueIndex(before: 1) == nil)
    #expect(boolArray.trueIndex(before: 2) == 1)
    #expect(boolArray.trueIndex(before: 3) == 1)
    #expect(boolArray.trueIndex(before: 4) == 1)
    #expect(boolArray.trueIndex(before: 5) == 1)
    #expect(boolArray.trueIndex(before: 6) == 5)
    #expect(boolArray.trueIndex(before: 7) == 5)
  }
}
