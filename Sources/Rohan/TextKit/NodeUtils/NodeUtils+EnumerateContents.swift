// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  typealias EnumerateContentsBlock = DocumentManager.EnumerateContentsBlock

  /**
   Enumerate contents in a range.
   Closure `block` returns `true` to continue enumeration, `false` to stop.
   */
  static func enumerateContents(
    _ range: RhTextRange, _ tree: RootNode,
    using block: EnumerateContentsBlock
  ) throws {
    let location = range.location.asTextLocationSlice
    let endLocation = range.endLocation.asTextLocationSlice
    _ = try enumerateContents(location, endLocation, tree, using: block)
  }

  /// Enumerate contents in a range.
  /// - Returns: false if enumeration is stopped by `block`; true otherwise.
  static func enumerateContents(
    _ location: TextLocationSlice, _ endLocation: TextLocationSlice, _ subtree: Node,
    using block: EnumerateContentsBlock
  ) throws -> Bool {
    switch subtree {
    case let textNode as TextNode:
      assert(location.count == 1 && endLocation.count == 1)
      let range = location.offset..<endLocation.offset
      return try enumerateContents(in: range, textNode: textNode, using: block)

    case let elementNode as ElementNode:
      // if we are at the last index, do enumeration
      if location.count == 1 && endLocation.count == 1 {
        let range = location.offset..<endLocation.offset
        return try enumerateContents(in: range, elementNode: elementNode, using: block)
      }
      // ASSERT: location.count > 1 ∨ endLocation.count > 1
      else if location.count == 1 {  // ASSERT: endLocation.count > 1
        // obtain index and end index
        let index = location.offset
        guard let endIndex = endLocation.indices.first?.index(),
          0..<elementNode.childCount ~= endIndex
        else { throw SatzError(.InvalidTextLocation) }
        // enumerate contents in the first part
        let part0 = index..<endIndex
        let shouldContinue =
          try enumerateContents(in: part0, elementNode: elementNode, using: block)
        guard shouldContinue else { return false }
        // enumerate contents in the second part
        let endChild = elementNode.getChild(endIndex)
        return try enumerateContentsAtEnd(endLocation.dropFirst(), endChild, using: block)
      }
      else if endLocation.count == 1 {  // ASSERT: location.count > 1
        // obtain index and end index
        guard let index = location.indices.first?.index(),
          0..<elementNode.childCount ~= index
        else { throw SatzError(.InvalidTextLocation) }
        let endIndex = endLocation.offset
        // enumerate contents in the first part
        let child = elementNode.getChild(index)
        let shouldContinue =
          try enumerateContentsAtBeginning(location.dropFirst(), child, using: block)
        guard shouldContinue else { return false }
        // enumerate contents in the second part
        let part1 = (index + 1)..<endIndex
        return try enumerateContents(in: part1, elementNode: elementNode, using: block)
      }
      else {  // ASSERT: location.count > 1 ∧ endLocation.count > 1
        guard let index = location.indices.first?.index(),
          let endIndex = endLocation.indices.first?.index(),
          0..<elementNode.childCount ~= index,
          0..<elementNode.childCount ~= endIndex
        else { throw SatzError(.InvalidTextLocation) }

        if index == endIndex {
          let child = elementNode.getChild(index)
          return try enumerateContents(
            location.dropFirst(), endLocation.dropFirst(), child, using: block)
        }
        // ASSERT: index < endIndex
        else {
          // enumerate contents in the first part
          let child = elementNode.getChild(index)
          var shouldContinue =
            try enumerateContentsAtBeginning(location.dropFirst(), child, using: block)
          guard shouldContinue else { return false }
          // enumerate contents in the middle part
          let range = (index + 1)..<endIndex
          shouldContinue =
            try enumerateContents(in: range, elementNode: elementNode, using: block)
          guard shouldContinue else { return false }
          // enumerate contents in the last part
          let endChild = elementNode.getChild(endIndex)
          return try enumerateContentsAtEnd(
            endLocation.dropFirst(), endChild, using: block)
        }
      }

    case let argumentNode as ArgumentNode:
      return try argumentNode.enumerateContents(location, endLocation, using: block)

    default:
      assert(isApplyNode(subtree) || isMathNode(subtree))

      var node: Node = subtree
      var location: TextLocationSlice = location
      var endLocation: TextLocationSlice = endLocation

      func isForked(
        _ location: TextLocationSlice, _ endLocation: TextLocationSlice
      ) -> Bool {
        location.indices.first! != endLocation.indices.first!
      }

      repeat {
        // check invariant
        guard location.count > 1 && endLocation.count > 1,
          !isForked(location, endLocation)
        else { throw SatzError(.InvalidTextLocation) }
        // make progress
        guard let child = node.getChild(location.indices.first!)
        else { throw SatzError(.InvalidTextLocation) }
        node = child
        location = location.dropFirst()
        endLocation = endLocation.dropFirst()
      } while !isArgumentNode(node) && !isElementNode(node) && !isTextNode(node)
      // recurse
      return try enumerateContents(location, endLocation, node, using: block)
    }
  }

  /**
   Enumerate contents in a range.
   - Returns: `false` if enumeration is stopped by `block`, `true` otherwise.
   */
  private static func enumerateContents(
    in range: Range<Int>, textNode: TextNode,
    using block: EnumerateContentsBlock
  ) throws -> Bool {
    // empty range is valid, but enumerate nothing
    guard !range.isEmpty else { return true }
    // validate range
    guard 0..<textNode.u16length ~= range.lowerBound,
      0...textNode.u16length ~= range.upperBound
    else { throw SatzError(.InvalidTextLocation) }

    if 0..<textNode.u16length == range {
      return block(nil, .original(textNode))
    }
    else {
      let slicedText = textNode.getSlice(for: range)
      return block(nil, .slicedText(slicedText))
    }
  }

  /**
   Enumerate contents in a range.
   - Returns: `false` if enumeration is stopped by `block`, `true` otherwise.
   */
  private static func enumerateContents(
    in range: Range<Int>, elementNode: ElementNode,
    using block: EnumerateContentsBlock
  ) throws -> Bool {
    // empty range is valid, but enumerate nothing
    guard !range.isEmpty else { return true }
    // validate range
    let childCount = elementNode.childCount
    guard 0..<childCount ~= range.lowerBound,
      0...childCount ~= range.upperBound
    else { throw SatzError(.InvalidTextLocation) }
    var shouldContinue = true
    for i in range {
      let child = elementNode.getChild(i)
      shouldContinue = block(nil, .original(child))
      guard shouldContinue else { break }
    }
    return shouldContinue
  }

  // MARK: - Start Section

  /**
   Enumerate contents in node starting from the given location to the end of the node.
   - Returns: `false` if enumeration is stopped by `block`, `true` otherwise.
   */
  private static func enumerateContentsAtBeginning(
    _ location: TextLocationSlice, _ node: Node,
    using block: EnumerateContentsBlock
  ) throws -> Bool {
    guard let partialNode = try preparePartialNodeForBeginning(location, node: node)
    else { return true }
    return block(nil, partialNode)
  }

  /**
   Prepare a partial node for enumeration.
   - Returns: `nil` if the location selects nothing. Otherwise, a partial node.
   */
  private static func preparePartialNodeForBeginning(
    _ location: TextLocationSlice, node: Node
  ) throws -> PartialNode? {
    switch node {
    case let textNode as TextNode:
      return try preparePartialNodeForBeginning(location, textNode: textNode)

    case let elementNode as ElementNode:
      return try preparePartialNodeForBeginning(location, elementNode: elementNode)

    default:
      throw SatzError(.ElementOrTextNodeExpected)
    }
  }

  private static func preparePartialNodeForBeginning(
    _ location: TextLocationSlice, elementNode: ElementNode
  ) throws -> PartialNode {
    if location.count == 1 {
      let index = location.offset
      guard 0...elementNode.childCount ~= index
      else { throw SatzError(.InvalidTextLocation) }
      let range = index..<elementNode.childCount
      return preparePartialElement(range, elementNode: elementNode)
    }
    else {  // ASSERT: location.count > 1
      guard let index = location.indices.first?.index(),
        0..<elementNode.childCount ~= index
      else { throw SatzError(.InvalidTextLocation) }
      let child = elementNode.getChild(index)
      let partialChild =
        try preparePartialNodeForBeginning(location.dropFirst(), node: child)

      // special treatment for index = 0
      if index == 0,
        let partialChild, partialChild.isOriginal
      {
        return .original(elementNode)
      }
      else {
        let range = (index + 1)..<elementNode.childCount
        var slicedElement = preparePartialElement(range, elementNode: elementNode)
          .slicedElement()!
        if let partialChild {
          slicedElement.prependChild(partialChild)
        }
        return .slicedElement(slicedElement)
      }
    }
  }

  /**
   Prepare a partial element node for enumeration.
   - Returns: `nil` if the location selects nothing. Otherwise, a partial node.
   */
  private static func preparePartialNodeForBeginning(
    _ location: TextLocationSlice, textNode: TextNode
  ) throws -> PartialNode? {
    guard location.count == 1 else { throw SatzError(.InvalidTextLocation) }
    let offset = location.offset
    if offset == textNode.u16length {
      return nil
    }
    else if offset == 0 {
      return .original(textNode)
    }
    else {
      let range = offset..<textNode.u16length
      let slicedText = textNode.getSlice(for: range)
      return .slicedText(slicedText)
    }
  }

  // MARK: - End Section

  private static func enumerateContentsAtEnd(
    _ endLocation: TextLocationSlice, _ node: Node,
    using block: EnumerateContentsBlock
  ) throws -> Bool {
    guard let partialNode = try preparePartialNodeForEnd(endLocation, node: node)
    else { return true }
    return block(nil, partialNode)
  }

  /**
   Prepare a partial node for enumeration.
   - Returns: `nil` if the location selects nothing. Otherwise, a partial node.
   */
  private static func preparePartialNodeForEnd(
    _ endLocation: TextLocationSlice, node: Node
  ) throws -> PartialNode? {
    switch node {
    case let textNode as TextNode:
      return try preparePartialNodeForEnd(endLocation, textNode: textNode)

    case let elementNode as ElementNode:
      return try preparePartialNodeForEnd(endLocation, elementNode: elementNode)

    default:
      throw SatzError(.ElementOrTextNodeExpected)
    }
  }

  private static func preparePartialNodeForEnd(
    _ endLocation: TextLocationSlice, elementNode: ElementNode
  ) throws -> PartialNode {
    if endLocation.count == 1 {
      let endIndex = endLocation.offset
      guard 0...elementNode.childCount ~= endIndex
      else { throw SatzError(.InvalidTextLocation) }
      let range = 0..<endIndex
      return preparePartialElement(range, elementNode: elementNode)
    }
    else {  // ASSERT: endLocation.count > 1
      guard let endIndex = endLocation.indices.first?.index(),
        0..<elementNode.childCount ~= endIndex
      else { throw SatzError(.InvalidTextLocation) }
      let endChild = elementNode.getChild(endIndex)
      let partialChild =
        try preparePartialNodeForEnd(endLocation.dropFirst(), node: endChild)
      // special treatment for endIndex = childCount - 1
      if endIndex == elementNode.childCount - 1,
        let partialChild, partialChild.isOriginal
      {
        return .original(elementNode)
      }
      else {
        let range = 0..<endIndex
        var slicedElement = preparePartialElement(range, elementNode: elementNode)
          .slicedElement()!
        if let partialChild {
          slicedElement.appendChild(partialChild)
        }
        return .slicedElement(slicedElement)
      }
    }
  }

  /**
   Prepare a partial element node for enumeration.
   - Returns: `nil` if the location selects nothing. Otherwise, a partial node.
   */
  private static func preparePartialNodeForEnd(
    _ endLocation: TextLocationSlice, textNode: TextNode
  ) throws -> PartialNode? {
    guard endLocation.count == 1 else { throw SatzError(.InvalidTextLocation) }
    let endOffset = endLocation.offset

    if endOffset == 0 {
      return nil
    }
    else if endOffset == textNode.u16length {
      return .original(textNode)
    }
    else {
      let range = 0..<endOffset
      let slicedText = textNode.getSlice(for: range)
      return .slicedText(slicedText)
    }
  }

  // MARK: - Helper

  /**
   Prepare a partial element node for enumeration.
   - Parameters:
     - range: The range to enumerate.
     - elementNode: The element node.
   */
  private static func preparePartialElement(
    _ range: Range<Int>, elementNode: ElementNode
  ) -> PartialNode {
    // range can be empty
    // range can be the end position of the element
    precondition(0...elementNode.childCount ~= range.lowerBound)
    precondition(0...elementNode.childCount ~= range.upperBound)

    if range == 0..<elementNode.childCount {
      return .original(elementNode)
    }
    else {
      var slicedElement = SlicedElement(for: elementNode)
      for i in range {
        let child = elementNode.getChild(i)
        slicedElement.appendChild(.original(child))
      }
      return .slicedElement(slicedElement)
    }
  }
}
