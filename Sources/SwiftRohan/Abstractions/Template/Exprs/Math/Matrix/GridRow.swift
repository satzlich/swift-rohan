// Copyright 2024-2025 Lie Yan

/// Row of elements in a grid.
internal struct GridRow<Element: Codable>: Codable, Sequence {
  private var _elements: Array<Element>

  var isEmpty: Bool { _elements.isEmpty }
  var count: Int { _elements.count }

  subscript(_ index: Int) -> Element {
    get { _elements[index] }
    set { _elements[index] = newValue }
  }

  init(_ elements: Array<Element>) {
    self._elements = elements
  }

  func makeIterator() -> IndexingIterator<Array<Element>> {
    _elements.makeIterator()
  }

  mutating func insert(_ element: Element, at index: Int) {
    _elements.insert(element, at: index)
  }

  mutating func remove(at index: Int) -> Element {
    _elements.remove(at: index)
  }

  // MARK: - Codable

  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    _elements = try container.decode(Array<Element>.self)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(_elements)
  }
}
