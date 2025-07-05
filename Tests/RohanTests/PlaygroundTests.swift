// Copyright 2024-2025 Lie Yan

import AppKit
import DequeModule
import Testing

@testable import SwiftRohan

struct PlaygroundTests {
  var attributes: Dictionary<NSAttributedString.Key, Any> = [
    .font: NSFont.systemFont(ofSize: 10)
  ]

  @Test
  func nsAttributedString_size() {
    do {
      let attrString = NSAttributedString(string: "Hello", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 24.6875))
    }
    do {
      let attrString = NSAttributedString(string: "Jenny", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 28.583984375))
    }
    do {
      let attrString = NSAttributedString(string: "\u{00A0}", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 2.9296875))
    }
    do {
      let attrString = NSAttributedString(string: "\u{3000}", attributes: attributes)
      #expect(attrString.size().width.isNearlyEqual(to: 9.941634241245136))
    }
  }

  @Test(.disabled())
  func objectEquality() {
    final class TestObject {}

    let obj1 = TestObject()
    var objects = Deque<TestObject>()
    let n = 10000
    for _ in 0..<n {
      let obj2 = TestObject()
      objects.append(obj2)
    }
    objects.append(obj1)

    // measure time
    let clock = ContinuousClock()

    let count = 100
    let elapsed = clock.measure {
      for _ in 0..<count - 1 {
        _ = objects.firstIndex(where: { $0 === obj1 })
      }
      let index = objects.firstIndex(where: { $0 === obj1 })
      #expect(index == n)
    }
    print("Average time for \(count) iterations: \(elapsed / Double(count)) seconds")
  }
}
