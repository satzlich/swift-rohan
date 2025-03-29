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
      moveForward(&trace)
      return buildLocation(from: trace)

    case .backward:
      moveBackward(&trace)
      return buildLocation(from: trace)

    default:
      assertionFailure("Unexpected direction")
      return nil
    }
  }

  /// Move forward from the location given by trace until a valid insertion point.
  private static func moveForward(_ trace: inout [TraceElement]) {
    precondition(!trace.isEmpty)

    let last = trace.last!

    switch last.node {
    case let textNode as TextNode:
      let offset = last.index.index()!
      // if move forward by one character is successful, we are done
      if let destination = textNode.destinationOffset(for: offset, cOffsetBy: 1) {
        trace[trace.endIndex - 1] = last.with(index: .index(destination))
      }
      // otherwise, we are at the end of the text node.
      // Go up and move forward again.
      else {
        moveUpForward(&trace)
      }

    case let elementNode as ElementNode:  // including root node
      let index = last.index.index()!

      // if we are at the end of the element node
      if index == elementNode.childCount {
        let done = isRootNode(elementNode)
        // Otherwise, go up and move forward again.
        if !done {
          moveUpForward(&trace)
        }
      }
      // otherwise, try move into the index-th child
      else {
        moveDownOrForward(&trace)
      }

    case _ as ApplyNode, _ as ArgumentNode, _ as MathNode:
      _ = moveDownward_F(&trace) || moveUpForward(&trace)

    default:
      assertionFailure("Unexpected node type")
      moveUpForward(&trace)
    }
  }

  @discardableResult
  private static func moveUpForward(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)
    trace.removeLast()
    _moveForward(&trace)
    return true
  }

  @discardableResult
  private static func moveUpBackward(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)
    trace.removeLast()
    moveBackward(&trace)
    return true
  }

  @discardableResult
  private static func moveDownOrForward(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)
    let done = moveDownward_F(&trace)
    if !done {
      _moveForward(&trace)
    }
    return true
  }

  /// Move forward from the location given by trace until a valid insertion point.
  /// The first step is to move over a child node.
  private static func _moveForward(_ trace: inout [TraceElement]) {
    precondition(!trace.isEmpty)

    let last = trace.last!

    switch last.node {
    case let rootNode as RootNode:
      let index = last.index.index()!

      // if we are at the end of the root node, we are done
      if index == rootNode.childCount { return }
      // otherwise, skip the index-th child and stop
      assert(index < rootNode.childCount)
      trace[trace.endIndex - 1] = last.with(index: .index(index + 1))

    case let elementNode as ElementNode:
      let index = last.index.index()!

      // if we are at the end of the element node,
      // go up and move forward again
      if index == elementNode.childCount {
        moveUpForward(&trace)
        return
      }

      assert(index < elementNode.childCount)
      trace[trace.endIndex - 1] = last.with(index: .index(index + 1))
      let child = elementNode.getChild(index)
      if isTextNode(child) {
        moveForward(&trace)
      }

    case let argumentNode as ArgumentNode:
      let index = last.index.index()!

      // if we are at the end of the argument node, go up and move forward again
      if index == argumentNode.childCount {
        moveUpForward(&trace)
        return
      }

      assert(index < argumentNode.childCount)

      let child = argumentNode.getChild(index)
      trace[trace.endIndex - 1] = last.with(index: .index(index + 1))
      if isTextNode(child) {
        moveForward(&trace)
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!
      // if move forward to next component is successful, move downward
      if let destination = mathNode.destinationIndex(for: index, .forward) {
        trace[trace.endIndex - 1] = last.with(index: .mathIndex(destination))
        let done = moveDownward_F(&trace)
        assert(done)
      }
      // otherwise, go up and move forward again
      else {
        moveUpForward(&trace)
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!

      assert(index < applyNode.argumentCount)

      // if we are at the last argument, go up and move forward again
      if index + 1 == applyNode.argumentCount {
        moveUpForward(&trace)
      }
      else {
        trace[trace.endIndex - 1] = last.with(index: .argumentIndex(index + 1))
        moveDownOrForward(&trace)
      }

    default:
      assertionFailure("Unexpected node type")
      moveUpForward(&trace)
      return
    }
  }

  /// Move downward for the purpose of moving forward. Suffix "_F" in the function
  /// name stands for "forward".
  /// - Returns: True if move is successful; false otherwise.
  /// - Postcondition: If move is unsuccesful, trace is unchanged.
  private static func moveDownward_F(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)

    let last = trace.last!

    var node = last.node
    var index = last.index

    let count = trace.count

    repeat {
      guard let child = node.getChild(index),
        let newIndex = child.firstIndex()
      else {
        trace.removeLast(trace.count - count)
        return false
      }
      node = child
      index = newIndex
      trace.append(TraceElement(node, index))
    } while !isCursorAllowed(node)

    return true
  }

  /// Move backward from the location given by trace until a valid insertion point.
  private static func moveBackward(_ trace: inout [TraceElement]) {
    precondition(!trace.isEmpty)

    let last = trace.last!

    switch last.node {
    case let textNode as TextNode:
      let offset = last.index.index()!
      // if move backward by one character is successful, we are done
      if let destination = textNode.destinationOffset(for: offset, cOffsetBy: -1) {
        trace[trace.endIndex - 1] = last.with(index: .index(destination))
      }
      // otherwise, move up and move backward again
      else {
        moveUpBackward(&trace)
      }

    case _ as RootNode:
      let index = last.index.index()!

      if index == 0 {
        return
      }
      else {
        trace[trace.endIndex - 1] = last.with(index: .index(index - 1))
        _ = moveDownward_B(&trace)
      }

    case _ as ElementNode:
      assert(trace.count >= 2)

      let index = last.index.index()!

      if index == 0 {
        let last = trace.last!.node
        trace.removeLast()
        // for transprent node, move backward again
        if last.isTransparent {
          moveBackward(&trace)
        }
        else {
          let secondLast = trace.last!.node
          // if cursor is not allowed in second last node, move backward again
          if !isCursorAllowed(secondLast) {
            moveBackward(&trace)
          }
        }
      }
      else {
        assert(index > 0)
        trace[trace.endIndex - 1] = last.with(index: .index(index - 1))
        _ = moveDownward_B(&trace)
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!
      if index == 0 {
        trace.removeLast()
      }
      else {
        assert(index > 0)
        trace[trace.endIndex - 1] = last.with(index: .argumentIndex(index - 1))
        let child = applyNode.getArgument(index - 1)
        // guaranteed to be successful
        trace.append(TraceElement(child, .index(child.childCount)))
      }

    case _ as ArgumentNode:
      let index = last.index.index()!
      if index == 0 {
        moveUpBackward(&trace)
      }
      else {
        assert(index > 0)
        trace[trace.endIndex - 1] = last.with(index: .index(index - 1))
        _ = moveDownward_B(&trace)
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!
      if let destination = mathNode.destinationIndex(for: index, .backward) {
        trace[trace.endIndex - 1] = last.with(index: .mathIndex(destination))
        let component = mathNode.getComponent(destination)!
        trace.append(TraceElement(component, .index(component.childCount)))
      }
      else {
        trace.removeLast()
      }

    default:
      assertionFailure("Unexpected node type")
      return
    }
  }

  /// Move downward for the purpose of moving backward. Suffix "_B" in the function
  /// name stands for "backward".
  /// - Returns: true if move is successful; false otherwise.
  /// - Postcondition: If move is unsuccessful, trace is unchanged.
  private static func moveDownward_B(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)

    let last = trace.last!

    var node = last.node
    var index = last.index

    let count = trace.count

    repeat {
      guard let child = node.getChild(index),
        let newIndex = child.lastIndex()
      else {
        trace.removeLast(trace.count - count)
        return false
      }
      node = child
      index = newIndex
      trace.append(TraceElement(node, index))
    } while !isCursorAllowed(node)

    return true
  }

  /// Returns true if insertion point is allowed immediately within the node.
  static func isCursorAllowed(_ node: Node) -> Bool {
    isArgumentNode(node) || isElementNode(node) || isTextNode(node)
  }
}
