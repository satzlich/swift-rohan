// Copyright 2024-2025 Lie Yan

import Foundation

struct Trace {
  private(set) var elements: [TraceElement]

  var isEmpty: Bool { @inline(__always) get { elements.isEmpty } }
  var count: Int { @inline(__always) get { elements.count } }

  var last: TraceElement? { @inline(__always) get { elements.last } }

  init(_ elements: [TraceElement]) {
    self.elements = elements
  }

  mutating func append(_ node: Node, _ index: RohanIndex) {
    elements.append(.init(node, index))
  }

  mutating func truncate(to count: Int) {
    precondition(count <= elements.count)
    elements.removeLast(elements.count - count)
  }

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

    case let rootNode as RootNode:
      let index = last.index.index()!
      let n = rootNode.childCount

      if n == 0 {
        // do nothing
      }
      else if index == n {
        if !rootNode.getChild(n - 1).isTransparent {
          // do nothing
        }
        else {
          self.moveTo(.index(n - 1))
          _ = self.moveDownToLast()
        }
      }
      else {
        self.moveDownOrForward()
      }

    case let elementNode as ElementNode:  // including root node
      let index = last.index.index()!

      if index == elementNode.childCount {
        self.moveUpForward()
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

  /// Move the caret forward to a valid insertion point by first making a "giant
  /// step".
  @discardableResult
  private mutating func moveForward_GS() -> Bool {
    precondition(!isEmpty)

    let last = self.last!

    switch last.node {
    case let rootNode as RootNode:
      let index = last.index.index()!

      let n = rootNode.childCount

      if n == 0 {
        // do nothing
      }
      else if index == n || index + 1 == n {
        if !rootNode.getChild(n - 1).isTransparent {
          self.moveTo(.index(n))
        }
        else {
          self.moveTo(.index(n - 1))
          _ = self.moveDownToLast()
        }
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

    case let rootNode as RootNode:
      let index = last.index.index()!
      let n = rootNode.childCount

      if n == 0 {
        // do nothing
      }
      else if index == 0 {
        if !rootNode.getChild(0).isTransparent {
          // do nothing
        }
        else {
          self.moveDownToFirst()
        }
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
        self.moveUp()
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
        self.moveDownToLast()
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

  /// Move at the same depth to given index.
  @inline(__always)
  private mutating func moveTo(_ index: RohanIndex) {
    precondition(!isEmpty)

    let last = self.last!
    assert(index.isSameType(as: last.index))

    elements[count - 1] = last.with(index: index)
  }

  /// Move down the first descendant.
  /// - Returns: true if move is successful; false otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @discardableResult
  @inline(__always)
  private mutating func moveDownToFirst() -> Bool {
    moveDownToDescendant { $0.firstIndex() }
  }

  /// Move down to the last descendant.
  /// - Returns: true if move is successful; false otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @discardableResult
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
        self.truncate(to: count)
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
    elements.removeLast()
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

/// Returns true if insertion point is allowed immediately within the node.
private func isCursorAllowed(_ node: Node) -> Bool {
  isArgumentNode(node) || isElementNode(node) || isTextNode(node)
}
