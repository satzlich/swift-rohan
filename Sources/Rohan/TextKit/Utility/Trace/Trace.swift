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
        moveTo(.index(destination))
      }
      else {
        moveUp()
        moveForward_GS()
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
          moveTo(.index(n - 1))
          _ = moveDownToLast()
        }
      }
      else {
        moveDownToFirst().or_else { moveForward_GS() }
      }

    case let elementNode as ElementNode:
      let index = last.index.index()!

      if index == elementNode.childCount {
        moveUp()
        moveForward_GS()
      }
      else {
        moveDownToFirst().or_else { moveForward_GS() }
      }

    case _ as ApplyNode, _ as ArgumentNode, _ as MathNode:
      moveDownToFirst().or_else {
        moveUp()
        moveForward_GS()
      }

    default:
      assertionFailure("Unexpected node type")
      moveUp()
      moveForward_GS()
    }
  }

  /// Move the caret forward to a valid insertion point by first making a "giant
  /// step".
  private mutating func moveForward_GS() {
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
          moveTo(.index(n))
        }
        else {
          moveTo(.index(n - 1))
          _ = moveDownToLast()
        }
      }
      else {
        moveTo(.index(index + 1))
      }

    case let elementNode as ElementNode:
      let index = last.index.index()!

      if index == elementNode.childCount {
        moveUp()
        moveForward_GS()
      }
      else {
        moveTo(.index(index + 1))
        let child = elementNode.getChild(index)
        if isTextNode(child) {
          moveForward()
        }
      }

    case let argumentNode as ArgumentNode:
      let index = last.index.index()!

      if index == argumentNode.childCount {
        moveUp()
        moveForward_GS()
      }
      else {
        let child = argumentNode.getChild(index)
        moveTo(.index(index + 1))
        if isTextNode(child) {
          moveForward()
        }
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!

      if let destination = mathNode.destinationIndex(for: index, .forward) {
        moveTo(.mathIndex(destination))
        let token: Void? = moveDownToFirst()
        assert(token != nil)
      }
      else {
        moveUp()
        moveForward_GS()
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!

      assert(index < applyNode.argumentCount)

      if index + 1 == applyNode.argumentCount {
        moveUp()
        moveForward_GS()
      }
      else {
        moveTo(.argumentIndex(index + 1))
        moveDownToFirst().or_else { moveForward_GS() }
      }

    default:
      assertionFailure("Unexpected node type")
      moveUp()
      moveForward_GS()
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
        moveTo(.index(destination))
      }
      else {
        moveUp()
        moveBackward()
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
          moveDownToFirst()
        }
      }
      else {
        moveTo(.index(index - 1))
        _ = moveDownToLast()
      }

    case _ as ElementNode:
      assert(self.count >= 2)

      let index = last.index.index()!

      if index == 0 {
        let lastNode = last.node
        moveUp()

        // for transparent node
        if lastNode.isTransparent {
          moveBackward()
        }
        else {
          let secondLast = self.last!.node
          if !isCursorAllowed(secondLast) {
            moveBackward()
          }
        }
      }
      else {
        assert(index > 0)

        moveTo(.index(index - 1))
        _ = moveDownToLast()
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!
      if index == 0 {
        moveUp()
      }
      else {
        assert(index > 0)
        moveTo(.argumentIndex(index - 1))
        let child = applyNode.getArgument(index - 1)
        self.append(child, .index(child.childCount))
      }

    case _ as ArgumentNode:
      let index = last.index.index()!
      if index == 0 {
        moveUp()
        moveBackward()
      }
      else {
        assert(index > 0)
        moveTo(.index(index - 1))
        moveDownToLast()
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!
      if let destination = mathNode.destinationIndex(for: index, .backward) {
        moveTo(.mathIndex(destination))
        let component = mathNode.getComponent(destination)!
        self.append(component, .index(component.childCount))
      }
      else {
        moveUp()
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
  /// - Returns: () if move is successful; nil otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @discardableResult
  @inline(__always)
  private mutating func moveDownToFirst() -> Optional<Void> {
    moveDownToDescendant { $0.firstIndex() }
  }

  /// Move down to the last descendant.
  /// - Returns: () if move is successful; nil otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @discardableResult
  @inline(__always)
  private mutating func moveDownToLast() -> Optional<Void> {
    moveDownToDescendant { $0.lastIndex() }
  }

  private mutating func moveDownToDescendant(_ f: (Node) -> RohanIndex?) -> Optional<Void>
  {
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
        return nil
      }
      node = child
      index = target

      self.append(node, index)
    } while !isCursorAllowed(node)

    return ()
  }

  @inline(__always)
  private mutating func moveUp() {
    precondition(!isEmpty)
    elements.removeLast()
  }
}

/// Returns true if insertion point is allowed immediately within the node.
private func isCursorAllowed(_ node: Node) -> Bool {
  isArgumentNode(node) || isElementNode(node) || isTextNode(node)
}
