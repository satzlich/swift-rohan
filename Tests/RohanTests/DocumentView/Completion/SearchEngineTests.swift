import Foundation
import Testing

@testable import SwiftRohan

struct SearchEngineTests {
  @Test
  func coverage() {
    typealias SearchEngine = SwiftRohan.SearchEngine<Int>

    let searchEngine = SearchEngine(gramSize: 2)
    _ = searchEngine.gramSize
    _ = searchEngine.count

    do {
      // insert
      let records: Array<SearchEngine.Element> = [
        ("apple", 1),
        ("banana", 2),
        ("cherry", 3),
        ("date", 4),
        ("elderberry", 5),
      ]
      searchEngine.insert(contentsOf: records)
      searchEngine.insert("fig", value: 6)
      #expect(searchEngine.count == 6)
      // delete/update
      searchEngine.delete("banana")
      searchEngine.update("cherry", newValue: 7)
      #expect(searchEngine.count == 5)
      // get
      #expect(searchEngine.get("apple") == 1)
      #expect(searchEngine.get("banana") == nil)
      // compact
      searchEngine.compact()
    }

    let maxResults = 10
    do {
      let results = searchEngine.search("c", maxResults)
      #expect(results.count == 1)
      #expect(results.first?.key == "cherry")
      #expect(results.first?.value == 7)
    }
    do {
      let results = searchEngine.search("C", maxResults)
      #expect(results.count == 1)
      #expect(results.first?.key == "cherry")
      #expect(results.first?.value == 7)
    }
    do {
      let results = searchEngine.search("ch", maxResults)
      #expect(results.count == 1)
      #expect(results.first?.key == "cherry")
      #expect(results.first?.value == 7)
    }
    do {
      let results = searchEngine.search("cherry", maxResults)
      #expect(results.count == 1)
      #expect(results.first?.key == "cherry")
      #expect(results.first?.value == 7)
    }
    do {
      let emptyResults = searchEngine.search("xyz", maxResults)
      #expect(emptyResults.isEmpty)
    }

    // add more records
    do {
      let records: Array<SearchEngine.Element> = [
        ("grape", 8),
        ("honeydew", 9),
        ("kiwi", 10),
        ("lemon", 11),
        ("mango", 12),
        ("nectarine", 13),
        ("orange", 14),
        ("papaya", 15),
        ("pine", 16),
        ("pineapple", 17),
        ("quince", 18),
        ("raspberry", 19),
      ]
      searchEngine.insert(contentsOf: records)
    }
    do {
      let results = searchEngine.search("appe", maxResults)
      _ = results.sorted()
      #expect(results.count == 2)
    }
    do {
      let results = searchEngine.search("pie", maxResults)
      _ = results.sorted()
      #expect(results.count == 2)
    }
    // n-gram
    do {
      let results = searchEngine.search("ang", maxResults)
      _ = results.sorted()
      #expect(results.count == 2)
    }
    // subseq
    do {
      let results = searchEngine.search("ey", maxResults)
      _ = results.sorted()
      #expect(results.count == 4)
    }
  }
}
