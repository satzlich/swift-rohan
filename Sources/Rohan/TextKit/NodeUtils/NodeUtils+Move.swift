// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  /// Move caret to the next/previous location.
  /// - Returns: The new location of the caret. Nil if the given location is invalid.
  static func destinationLocation(
    for location: TextLocation, _ direction: TextSelectionNavigation.Direction,
    _ rootNode: RootNode
  ) -> TextLocation? {
    precondition([.forward, .backward].contains(direction))

    guard var trace = buildTrace(for: location, rootNode) else { return nil }

    switch direction {
    case .forward:
      trace.moveForward()
      return buildLocation(from: trace)

    case .backward:
      trace.moveBackward()
      return buildLocation(from: trace)

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }
}

/// Returns true if insertion point is allowed immediately within the node.
private func isCursorAllowed(_ node: Node) -> Bool {
  isArgumentNode(node) || isElementNode(node) || isTextNode(node)
}

fileprivate extension Array<TraceElement> {
  /// Move the caret forward to a valid insertion point.
  mutating func moveForward() {
    precondition(!isEmpty)

    let last = self.last!

    switch last.node {
    case let textNode as TextNode:
      let offset = last.index.index()!
      if let destination = textNode.destinationOffset(for: offset, cOffsetBy: 1) {
        self.moveTo(.index(destination))
      }
      else {
        self.moveUpForward()
      }

    case let elementNode as ElementNode:  // including root node
      let index = last.index.index()!

      if index == elementNode.childCount {
        _ = isRootNode(elementNode) || self.moveUpForward()
      }
      else {
        self.moveDownOrForward()
      }

    case _ as ApplyNode, _ as ArgumentNode, _ as MathNode:
      _ = self.moveDownToFirst() || self.moveUpForward()

    default:
      assertionFailure("Unexpected node type")
      self.moveUpForward()
    }
  }

  /// Move the caret backward to a valid insertion point.
  mutating func moveBackward() {
    precondition(!isEmpty)

    let last = self.last!

    switch last.node {
    case let textNode as TextNode:
      let offset = last.index.index()!
      if let destination = textNode.destinationOffset(for: offset, cOffsetBy: -1) {
        self.moveTo(.index(destination))
      }
      else {
        self.moveUpBackward()
      }

    case _ as RootNode:
      let index = last.index.index()!

      if index == 0 {
        return
      }
      else {
        self.moveTo(.index(index - 1))
        _ = self.moveDownToLast()
      }

    case _ as ElementNode:
      assert(self.count >= 2)

      let index = last.index.index()!

      if index == 0 {
        let lastNode = last.node
        self.moveUp()

        // for transparent node
        if lastNode.isTransparent {
          self.moveBackward()
        }
        else {
          let secondLast = self.last!.node
          if !isCursorAllowed(secondLast) {
            self.moveBackward()
          }
        }
      }
      else {
        assert(index > 0)

        self.moveTo(.index(index - 1))
        _ = self.moveDownToLast()
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!
      if index == 0 {
        self.removeLast()
      }
      else {
        assert(index > 0)
        self.moveTo(.argumentIndex(index - 1))
        let child = applyNode.getArgument(index - 1)
        self.append(child, .index(child.childCount))
      }

    case _ as ArgumentNode:
      let index = last.index.index()!
      if index == 0 {
        self.moveUpBackward()
      }
      else {
        assert(index > 0)
        self.moveTo(.index(index - 1))
        _ = self.moveDownToLast()
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!
      if let destination = mathNode.destinationIndex(for: index, .backward) {
        self.moveTo(.mathIndex(destination))
        let component = mathNode.getComponent(destination)!
        self.append(component, .index(component.childCount))
      }
      else {
        self.moveUp()
      }

    default:
      assertionFailure("Unexpected node type")
    }
  }

  /// Move the caret forward to a valid insertion point by first making a "giant
  /// step".
  private mutating func moveForward_GS() -> Bool {
    precondition(!isEmpty)

    let last = self.last!

    switch last.node {
    case let rootNode as RootNode:
      let index = last.index.index()!

      if index == rootNode.childCount {
        // do nothing
      }
      else {
        self.moveTo(.index(index + 1))
      }

    case let elementNode as ElementNode:
      let index = last.index.index()!

      if index == elementNode.childCount {
        self.moveUpForward()
      }
      else {
        self.moveTo(.index(index + 1))
        let child = elementNode.getChild(index)
        if isTextNode(child) {
          self.moveForward()
        }
      }

    case let argumentNode as ArgumentNode:
      let index = last.index.index()!

      if index == argumentNode.childCount {
        self.moveUpForward()
      }
      else {
        let child = argumentNode.getChild(index)
        self.moveTo(.index(index + 1))
        if isTextNode(child) {
          self.moveForward()
        }
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!

      if let destination = mathNode.destinationIndex(for: index, .forward) {
        self.moveTo(.mathIndex(destination))
        let done = self.moveDownToFirst()
        assert(done)
      }
      else {
        self.moveUpForward()
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!

      assert(index < applyNode.argumentCount)

      if index + 1 == applyNode.argumentCount {
        self.moveUpForward()
      }
      else {
        self.moveTo(.argumentIndex(index + 1))
        self.moveDownOrForward()
      }

    default:
      assertionFailure("Unexpected node type")
      self.moveUpForward()
    }

    return true
  }

  /// Append a new node and index to the trace.
  @inline(__always)
  mutating func append(_ node: Node, _ index: RohanIndex) {
    self.append(TraceElement(node, index))
  }

  /// Move at the same depth to given index.
  @inline(__always)
  private mutating func moveTo(_ index: RohanIndex) {
    precondition(!isEmpty)

    let last = self.last!
    assert(index.isSameType(as: last.index))

    self[self.endIndex - 1] = last.with(index: index)
  }

  /// Move down the first descendant.
  /// - Returns: true if move is successful; false otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @inline(__always)
  private mutating func moveDownToFirst() -> Bool {
    moveDownToDescendant { $0.firstIndex() }
  }

  /// Move down to the last descendant.
  /// - Returns: true if move is successful; false otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @inline(__always)
  private mutating func moveDownToLast() -> Bool {
    moveDownToDescendant { $0.lastIndex() }
  }

  private mutating func moveDownToDescendant(_ f: (Node) -> RohanIndex?) -> Bool {
    precondition(!isEmpty)

    let last = self.last!

    var node = last.node
    var index = last.index

    let count = self.count

    repeat {
      guard let child = node.getChild(index),
        let target = f(child)
      else {
        self.removeLast(self.count - count)
        return false
      }
      node = child
      index = target

      self.append(node, index)
    } while !isCursorAllowed(node)

    return true
  }

  @inline(__always)
  private mutating func moveUp() {
    precondition(!isEmpty)
    self.removeLast()
  }

  @inline(__always)
  @discardableResult
  private mutating func moveUpForward() -> Bool {
    precondition(!isEmpty)
    self.moveUp()
    self.moveForward_GS()
    return true
  }

  @inline(__always)
  @discardableResult
  private mutating func moveUpBackward() -> Bool {
    precondition(!isEmpty)
    moveUp()
    moveBackward()
    return true
  }

  @inline(__always)
  @discardableResult
  private mutating func moveDownOrForward() -> Bool {
    precondition(!isEmpty)
    return moveDownToFirst() || moveForward_GS()
  }
}
