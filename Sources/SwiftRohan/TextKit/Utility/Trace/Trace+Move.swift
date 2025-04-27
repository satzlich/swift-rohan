// Copyright 2024-2025 Lie Yan

import Foundation

extension Trace {
  /// Move at the same depth to given index.
  @inline(__always)
  mutating func moveTo(_ index: RohanIndex) {
    precondition(!isEmpty)
    _elements[endIndex - 1] = self.last!.with(index: index)
  }

  /// Move the caret forward to a valid insertion point.
  mutating func moveForward() {
    precondition(!isEmpty)

    let (lastNode, lastIndex) = self.last!.asTuple

    switch lastNode {
    case let textNode as TextNode:
      let offset = lastIndex.index()!
      if let destination = textNode.destinationOffset(for: offset, cOffsetBy: 1) {
        moveTo(.index(destination))
      }
      else {
        moveUp()
        moveForward_GS()
      }

    case let rootNode as RootNode:
      let index = lastIndex.index()!
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
          tryMoveDownToEnd()
        }
      }
      else {
        tryMoveDownToBeginning().or_else { moveForward_GS() }
      }

    case let elementNode as ElementNode:
      let index = lastIndex.index()!
      if index == elementNode.childCount {
        moveUp()
        moveForward_GS()
      }
      else {
        tryMoveDownToBeginning().or_else { moveForward_GS() }
      }

    case _ as ApplyNode, _ as ArgumentNode, _ as MathNode, _ as MatrixNode:
      tryMoveDownToBeginning().or_else {
        moveUp()
        moveForward_GS()
      }

    default:
      assertionFailure("Unexpected node type")
      moveUp()
      moveForward_GS()
    }
  }

  /// Move the caret to a valid insertion point after making a "giant step".
  /// - Note: a __giant step__ is a move that skips a child position.
  private mutating func moveForward_GS() {
    precondition(!isEmpty)

    let (lastNode, lastIndex) = self.last!.asTuple

    switch lastNode {
    case let rootNode as RootNode:
      let index = lastIndex.index()!
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
          tryMoveDownToEnd()
        }
      }
      else {
        assert(index + 1 < n)
        moveTo(.index(index + 1))
      }

    case let node as ElementNode:
      let index = lastIndex.index()!
      if index == node.childCount {
        moveUp()
        moveForward_GS()
      }
      else {
        assert(index < node.childCount)
        moveTo(.index(index + 1))
        if isTextNode(node.getChild(index)) {
          moveForward()
        }
      }

    // VERBATIM from "case let node as ElementNode:"
    case let node as ArgumentNode:
      let index = lastIndex.index()!
      if index == node.childCount {
        moveUp()
        moveForward_GS()
      }
      else {
        assert(index < node.childCount)
        moveTo(.index(index + 1))
        if isTextNode(node.getChild(index)) {
          moveForward()
        }
      }

    case let mathNode as MathNode:
      let index = lastIndex.mathIndex()!
      if let destination = mathNode.destinationIndex(for: index, .forward) {
        moveTo(.mathIndex(destination))
        let success: Void? = tryMoveDownToBeginning()
        assert(success != nil)
      }
      else {
        moveUp()
        moveForward_GS()
      }

    case let matrixNode as MatrixNode:
      let index = lastIndex.gridIndex()!
      if let destination = matrixNode.destinationIndex(for: index, .forward) {
        moveTo(.gridIndex(destination))
        let success: Void? = tryMoveDownToBeginning()
        assert(success != nil)
      }
      else {
        moveUp()
        moveForward_GS()
      }

    case let applyNode as ApplyNode:
      let index = lastIndex.argumentIndex()!
      assert(index < applyNode.argumentCount)
      if index + 1 == applyNode.argumentCount {
        moveUp()
        moveForward_GS()
      }
      else {
        moveTo(.argumentIndex(index + 1))
        tryMoveDownToBeginning().or_else { moveForward_GS() }
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

    let (lastNode, lastIndex) = self.last!.asTuple

    switch lastNode {
    case let textNode as TextNode:
      let offset = lastIndex.index()!
      if let destination = textNode.destinationOffset(for: offset, cOffsetBy: -1) {
        moveTo(.index(destination))
      }
      else {
        moveUp()
        moveBackward()
      }

    case let rootNode as RootNode:
      let index = lastIndex.index()!
      if rootNode.childCount == 0 {
        // do nothing
      }
      else if index == 0 {
        if !rootNode.getChild(0).isTransparent {
          // do nothing
        }
        else {
          tryMoveDownToBeginning()
        }
      }
      else {
        assert(index > 0)
        moveTo(.index(index - 1))
        tryMoveDownToEnd()
      }

    case _ as ElementNode:
      assert(self.count >= 2)
      let index = lastIndex.index()!
      if index == 0 {
        if lastNode.isTransparent {
          moveUp()
          moveBackward()
        }
        else {
          moveUp()
          let secondLastNode = self.last!.node
          assert(lastNode !== secondLastNode)
          if NodePolicy.isCursorAllowed(in: secondLastNode) == false {
            moveBackward()
          }
        }
      }
      else {
        assert(index > 0)
        moveTo(.index(index - 1))
        tryMoveDownToEnd()
      }

    case _ as ArgumentNode:
      let index = lastIndex.index()!
      if index == 0 {
        moveUp()
        moveBackward()
      }
      else {
        assert(index > 0)
        moveTo(.index(index - 1))
        tryMoveDownToEnd()
      }

    case let applyNode as ApplyNode:
      let index = lastIndex.argumentIndex()!
      if index == 0 {
        moveUp()
      }
      else {
        assert(index > 0)
        moveTo(.argumentIndex(index - 1))
        let child = applyNode.getArgument(index - 1)
        self.emplaceBack(child, .index(child.childCount))
      }

    case let mathNode as MathNode:
      let index = lastIndex.mathIndex()!
      if let destination = mathNode.destinationIndex(for: index, .backward) {
        moveTo(.mathIndex(destination))
        let component = mathNode.getComponent(destination)!
        self.emplaceBack(component, .index(component.childCount))
      }
      else {
        moveUp()
      }

    case let matrixNode as MatrixNode:
      let index = lastIndex.gridIndex()!
      if let destination = matrixNode.destinationIndex(for: index, .backward) {
        moveTo(.gridIndex(destination))
        let component = matrixNode.getElement(destination.row, destination.column)
        self.emplaceBack(component, .index(component.childCount))
      }
      else {
        moveUp()
      }

    default:
      assertionFailure("Unexpected node type")
      moveUp()
      moveBackward()
    }
  }

  @inline(__always)
  private mutating func moveUp() {
    precondition(!isEmpty)
    _elements.removeLast()
  }

  /// Move down to the beginning of the descendants.
  /// - Returns: () if move is successful; nil otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @inline(__always)
  private mutating func tryMoveDownToBeginning() -> Optional<Void> {
    tryMoveDownToDescendant { $0.firstIndex() }
  }

  /// Move down to the end of the descendants.
  /// - Returns: () if move is successful; nil otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  @inline(__always)
  private mutating func tryMoveDownToEnd() -> Optional<Void> {
    tryMoveDownToDescendant { $0.lastIndex() }
  }

  /// Move down to a descendant node that allows cursor with fewest moves.
  /// - Parameter getPositionIn: A function that returns the index of a child position.
  /// - Returns: () if move is successful; nil otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  private mutating func tryMoveDownToDescendant(
    _ getPositionIn: (Node) -> RohanIndex?
  ) -> Optional<Void> {
    precondition(!isEmpty)

    var (node, index) = self.last!.asTuple
    let n = self.count

    repeat {
      guard let child = node.getChild(index),
        let position = getPositionIn(child)
      else {
        self.truncate(to: n)
        return nil
      }
      node = child
      index = position
      self.emplaceBack(node, index)

    } while NodePolicy.isCursorAllowed(in: node) == false

    return ()
  }
}
