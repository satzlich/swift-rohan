// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct CounterArrayTests {

  @Test
  func empty() {
    let counterArray = CounterArray()
    #expect(counterArray.count == 0)
    #expect(counterArray.isEmpty)
    #expect(counterArray.trueCount == 0)
    #expect(counterArray.asBitArray == [])
  }

  @Test
  func subscripting() {
    let counterArray = CounterArray([false, true, false, true])

    #expect(counterArray[0] == false)
    #expect(counterArray[1] == true)
    #expect(counterArray[2] == false)
    #expect(counterArray[3] == true)
  }

  @Test
  func insert() {
    var counterArray = CounterArray()

    // insert true
    counterArray.insert(true, at: 0)
    #expect(counterArray.count == 1)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 1)
    #expect(counterArray.asBitArray == [true])

    // insert false
    counterArray.insert(false, at: 1)
    #expect(counterArray.count == 2)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 1)
    #expect(counterArray.asBitArray == [true, false])

    // insert empty
    counterArray.insert(contentsOf: [], at: 0)
    #expect(counterArray.count == 2)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 1)
    #expect(counterArray.asBitArray == [true, false])

    // insert [true, false]
    counterArray.insert(contentsOf: [true, false], at: 0)
    #expect(counterArray.count == 4)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 2)
    #expect(counterArray.asBitArray == [true, false, true, false])
  }

  @Test
  func remove() {
    var counterArray = CounterArray([false, true, false, true, true])

    // remove at index 4
    counterArray.remove(at: 4)
    #expect(counterArray.count == 4)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 2)
    #expect(counterArray.asBitArray == [false, true, false, true])

    // remove at index 0
    counterArray.remove(at: 0)
    #expect(counterArray.count == 3)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 2)
    #expect(counterArray.asBitArray == [true, false, true])

    // remove range [0,2)
    counterArray.removeSubrange(0..<2)
    #expect(counterArray.count == 1)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 1)
    #expect(counterArray.asBitArray == [true])

    // remove all
    counterArray.removeAll()
    #expect(counterArray.count == 0)
    #expect(counterArray.isEmpty)
    #expect(counterArray.trueCount == 0)
    #expect(counterArray.asBitArray == [])
  }

  @Test
  func replace() {
    var counterArray = CounterArray([false, true, false, true])

    // replace range [1,3) with [false, true]
    counterArray.replaceSubrange(1..<3, with: [false, true])
    #expect(counterArray.count == 4)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 2)
    #expect(counterArray.asBitArray == [false, false, true, true])
  }

  @Test
  func setValue() {
    var counterArray = CounterArray([false, true])
    // set value
    counterArray[0] = true
    #expect(counterArray.count == 2)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 2)
    #expect(counterArray.asBitArray == [true, true])

    // set value again
    counterArray[1] = false
    #expect(counterArray.count == 2)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 1)
    #expect(counterArray.asBitArray == [true, false])

    // set value again
    counterArray[1] = false
    #expect(counterArray.count == 2)
    #expect(!counterArray.isEmpty)
    #expect(counterArray.trueCount == 1)
    #expect(counterArray.asBitArray == [true, false])
  }
}
