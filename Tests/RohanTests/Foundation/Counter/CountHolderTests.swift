import Foundation
import Testing

@testable import SwiftRohan

struct CountHolderTests {

  final class TestingCountObserver: CountObserver {
    private(set) var count: Int = 0
    func countObserver(markAsDirty: Void) {
      count += 1
    }
  }

  private func initPair() -> (CountHolder, CountHolder) {
    let initial = CountHolder(.subsubsection)
    let final_ = CountHolder(.subsubsection)
    CountHolder.connect(initial, final_)
    return (initial, final_)
  }

  @Test
  func coverage() {
    let (initial, final_) = initPair()

    defer { withExtendedLifetime(initial, {}) }

    // declare count holders
    let section1 = CountHolder(.section)
    let subsection1 = CountHolder(.subsection)
    let equation1 = CountHolder(.equation)
    let subsection2 = CountHolder(.subsection)
    let section2 = CountHolder(.section)
    let subsubsection1 = CountHolder(.subsubsection)
    let subsubsection2 = CountHolder(.subsubsection)
    let equation2 = CountHolder(.equation)
    let list = [
      section1, subsection1, equation1, subsection2,
      section2, subsubsection1, subsubsection2, equation2,
    ]

    // declare observers
    let observer1 = TestingCountObserver()
    let observer2 = TestingCountObserver()

    // register observers
    subsection1.registerObserver(observer1)
    equation2.registerObserver(observer2)

    do {
      CountHolder.insert(contentsOf: list, before: final_)
      list[0].propagateDirty()
      #expect(final_.isDirty)

      #expect(section1.value(forName: .section) == 1)
      //
      #expect(section1.value(forName: .section) == 1)
      #expect(subsection1.value(forName: .subsection) == 1)
      //
      #expect(equation1.value(forName: .equation) == 1)
      //
      #expect(subsection2.value(forName: .section) == 1)
      #expect(subsection2.value(forName: .subsection) == 2)
      //
      #expect(section2.value(forName: .section) == 2)
      //
      #expect(subsubsection1.value(forName: .section) == 2)
      #expect(subsubsection1.value(forName: .subsection) == 0)
      #expect(subsubsection1.value(forName: .subsubsection) == 1)
      //
      #expect(subsubsection2.value(forName: .section) == 2)
      #expect(subsubsection2.value(forName: .subsection) == 0)
      #expect(subsubsection2.value(forName: .subsubsection) == 2)
      //
      #expect(equation2.value(forName: .equation) == 2)

      //
      #expect(observer1.count == 1)
      #expect(observer2.count == 1)
    }
    do {
      let begin = equation1
      let end = subsubsection2
      CountHolder.removeSubrange(begin, end)
      end.propagateDirty()

      #expect(section1.value(forName: .section) == 1)
      #expect(subsection1.value(forName: .section) == 1)
      #expect(subsection1.value(forName: .subsection) == 1)
      #expect(subsubsection2.value(forName: .section) == 1)
      #expect(subsubsection2.value(forName: .subsection) == 1)
      #expect(subsubsection2.value(forName: .subsubsection) == 1)
      #expect(equation2.value(forName: .equation) == 1)

      //
      #expect(observer1.count == 1)
      #expect(observer2.count == 2)
    }
  }

  @Test
  func insertRemove() {
    let (initial, final_) = initPair()

    defer { withExtendedLifetime(initial, {}) }

    // declare count holders
    let section1 = CountHolder(.section)
    let subsection1 = CountHolder(.subsection)
    let equation1 = CountHolder(.equation)

    // declare observers
    let observer1 = TestingCountObserver()
    let observer2 = TestingCountObserver()

    // register observers
    subsection1.registerObserver(observer1)
    equation1.registerObserver(observer2)

    // insert holders
    for holder in [section1, subsection1, equation1] {
      CountHolder.insert(holder, before: final_)
    }
    initial.propagateDirty()

    #expect(section1.value(forName: .section) == 1)
    #expect(subsection1.value(forName: .subsection) == 1)
    #expect(equation1.value(forName: .equation) == 1)
    #expect(observer1.count == 1)
    #expect(observer2.count == 1)

    // remove holders
    do {
      let isEmpty = CountHolder.remove(subsection1)
      initial.propagateDirty()
      #expect(isEmpty == false)
    }

    #expect(section1.value(forName: .section) == 1)
    #expect(equation1.value(forName: .subsection) == 0)
    #expect(equation1.value(forName: .equation) == 1)
  }

  @Test
  func insert() {
    let (initial, final_) = initPair()

    let section1 = CountHolder(.section)
    let subsection1 = CountHolder(.subsection)
    CountHolder.insert(contentsOf: [section1, subsection1], before: initial)
  }

  @Test
  func remove() {
    let (initial, final_) = initPair()

    do {
      let isEmpty = CountHolder.remove(initial)
      #expect(isEmpty == false)
    }
    do {
      let isEmpty = CountHolder.remove(final_)
      #expect(isEmpty == true)
    }
  }

  @Test
  func removeSubrange() {
    do {
      let (initial, final_) = initPair()
      CountHolder.removeSubrange(initial, initial)
      CountHolder.removeSubrange(initial, final_)
    }
  }

  @Test
  func removeSubrangeClosed() {
    let (initial, final_) = initPair()

    defer { withExtendedLifetime(initial, {}) }

    // declare count holders
    let section1 = CountHolder(.section)
    let subsection1 = CountHolder(.subsection)
    let equation1 = CountHolder(.equation)

    // insert holders
    for holder in [section1, subsection1, equation1] {
      CountHolder.insert(holder, before: final_)
    }
    initial.propagateDirty()

    #expect(CountHolder.countSubrange(initial, final_) == 4)

    // remove subrange
    do {
      let isEmpty = CountHolder.removeSubrange(section1, inclusive: equation1)
      initial.propagateDirty()
      #expect(isEmpty == false)
    }

    #expect(final_.value(forName: .section) == 0)
    #expect(final_.value(forName: .subsection) == 0)
    #expect(final_.value(forName: .equation) == 0)

    #expect(CountHolder.countSubrange(initial, inclusive: final_) == 2)

    do {
      var isEmpty = CountHolder.removeSubrange(final_, inclusive: final_)
      #expect(isEmpty == false)
      isEmpty = CountHolder.removeSubrange(initial, inclusive: initial)
      #expect(isEmpty == true)
    }
  }
}
