// Copyright 2024-2025 Lie Yan

internal struct _GridRow<Element: Codable>: Codable, Sequence {
  private var elements: [Element]

  var isEmpty: Bool { elements.isEmpty }

  var count: Int { elements.count }

  subscript(_ index: Int) -> Element {
    get { elements[index] }
    set { elements[index] = newValue }
  }

  init(_ elements: [Element]) {
    self.elements = elements
  }

  func with(elements: [Element]) -> _GridRow {
    _GridRow(elements)
  }

  func makeIterator() -> IndexingIterator<[Element]> {
    elements.makeIterator()
  }

  mutating func insert(_ element: Element, at index: Int) {
    elements.insert(element, at: index)
  }

  mutating func remove(at index: Int) -> Element {
    elements.remove(at: index)
  }

  // MARK: - Codable

  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    elements = try container.decode([Element].self)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(elements)
  }
}
