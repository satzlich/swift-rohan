// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class SearchEngineTests {
  var engine: SearchEngine<String>!
  let testDataSize = 10000
  let iterationCount = 1000
  let clock = ContinuousClock()

  @Test(.disabled())
  func populateDataset() {
    engine = SearchEngine<String>(gramSize: 2)

    // Measure insertion time
    let duration = clock.measure {
      for i in 0..<testDataSize {
        let name = generateRandomIdentifier(index: i)
        engine.insert(name, value: "func\(i)")
      }
    }
    print(duration)
    #expect(engine.count == testDataSize)
  }

  @Test(.disabled())
  func testSearchPerformance() {
    populateDataset()
    testSearchPerformance(with: "calc")  // prefix
    testSearchPerformance(with: "lcu")  // n-gram
    testSearchPerformance(with: "cma")  // subsequence
  }

  func testSearchPerformance(with key: String) {

    let totalTime = clock.measure {
      for _ in 0..<iterationCount {
        let results = engine.search(key, 10)
        #expect(!results.isEmpty)
      }
    }

    let averageTime = totalTime / iterationCount
    print("Average time for \"\(key)\": \(averageTime)")
    #expect(averageTime < .milliseconds(10), "Average search time should be under 5ms")
  }

  private func generateRandomIdentifier(index: Int) -> String {
    let prefixes = ["calculate", "compute", "get", "fetch", "process"]
    let suffixes = ["Value", "Result", "Data", "Sum", "Total"]
    let middle = ["", "By", "For", "In", "With"]

    return """
      \(prefixes.randomElement()!) \
      \(middle.randomElement()!) \
      \(suffixes.randomElement()!)_\(index)
      """
  }
}
