// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  /**
   Move the caret to the next/previous location in the document.
   - Returns: The new location of the caret. Nil if the caret cannot be moved.
   */
  static func destinationLocation(
    for location: TextLocation, _ direction: TextSelectionNavigation.Direction,
    _ rootNode: RootNode
  ) -> TextLocation? {
    precondition(Meta.matches(direction, .forward, .backward))

    var insertionPoint = InsertionPoint(location.asPath, isRectified: false)
    guard var trace = traceNodes(location, rootNode) else { return nil }

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

  /** Move forward until an insertion point. */
  private static func moveForward(_ trace: inout [TraceElement]) {
    precondition(!trace.isEmpty)

    let last = trace[trace.endIndex - 1]

    switch last.node {
    case let textNode as TextNode:
      let offset = last.index.index()!
      if let destination = textNode.destinationOffset(for: offset, offsetBy: 1) {
        trace[trace.endIndex - 1] = last.with(index: .index(destination))
      }
      else {  // leaving text node, we should move forward again
        trace.popLast()
        _moveForward(&trace)
      }

    case let rootNode as RootNode:
      let index = last.index.index()!
      if rootNode.childCount == 0 {
        return
      }
      else if index == rootNode.childCount {
        let lastIndex = rootNode.childCount - 1
        let lastChild = rootNode.getChild(lastIndex) as! ElementNode
        trace[trace.endIndex - 1] = last.with(index: .index(lastIndex))
        trace.append(TraceElement(lastChild, .index(lastChild.childCount)))
      }
      else {
        let count = trace.count
        if moveDownward_F(&trace) == false {
          assert(count == trace.count)
          _moveForward(&trace)
        }
      }

    case let elementNode as ElementNode:
      let index = last.index.index()!

      if index == elementNode.childCount {
        trace.popLast()
        _moveForward(&trace)
      }
      else {
        let count = trace.count
        if moveDownward_F(&trace) == false {
          assert(count == trace.count)
          _moveForward(&trace)
        }
      }

    case _ as ApplyNode, _ as ArgumentNode, _ as MathNode:
      let count = trace.count
      if moveDownward_F(&trace) == false {
        assert(count == trace.count)
        trace.popLast()
        _moveForward(&trace)
      }

    default:
      assertionFailure("Unexpected node type")
      trace.popLast()
      _moveForward(&trace)
      return
    }
  }

  private static func _moveForward(_ trace: inout [TraceElement]) {
    precondition(!trace.isEmpty)

    let last = trace[trace.endIndex - 1]

    switch last.node {
    case let rootNode as RootNode:
      let index = last.index.index()!
      assert(index < rootNode.childCount)
      if rootNode.childCount == 0 { return }
      let newIndex = index + 1
      if newIndex == rootNode.childCount {
        let lastIndex = rootNode.childCount - 1
        let lastChild = rootNode.getChild(lastIndex) as! ElementNode
        trace[trace.endIndex - 1] = last.with(index: .index(lastIndex))
        trace.append(TraceElement(lastChild, .index(lastChild.childCount)))
      }
      else {
        trace[trace.endIndex - 1] = last.with(index: .index(newIndex))
        let child = rootNode.getChild(newIndex) as! ElementNode
        trace.append(TraceElement(child, .index(0)))
      }

    case let elementNode as ElementNode:
      let index = last.index.index()!
      assert(index < elementNode.childCount)

      let childNode = elementNode.getChild(index)
      if childNode is TextNode {  // we are leaving text node
        trace[trace.endIndex - 1] = last.with(index: .index(index + 1))
        moveForward(&trace)
      }
      else {
        trace[trace.endIndex - 1] = last.with(index: .index(index + 1))
      }

    case let argumentNode as ArgumentNode:
      let index = last.index.index()!
      assert(index < argumentNode.childCount)

      let childNode = argumentNode.getChild(index)
      if childNode is TextNode {  // we are leaving text node
        trace[trace.endIndex - 1] = last.with(index: .index(index + 1))
        moveForward(&trace)
      }
      else {
        trace[trace.endIndex - 1] = last.with(index: .index(index + 1))
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!
      if let destination = mathNode.destinationIndex(for: index, .forward) {
        trace[trace.endIndex - 1] = last.with(index: .mathIndex(destination))
        moveDownward_F(&trace)
      }
      else {
        trace.popLast()
        _moveForward(&trace)
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!
      assert(index < applyNode.argumentCount)

      if index + 1 == applyNode.argumentCount {
        trace.popLast()
        _moveForward(&trace)
      }
      else {
        trace[trace.endIndex - 1] = last.with(index: .argumentIndex(index + 1))

        let count = trace.count
        if moveDownward_F(&trace) == false {
          assert(count == trace.count)
          _moveForward(&trace)
        }
      }

    default:
      assertionFailure("Unexpected node type")
      trace.popLast()
      _moveForward(&trace)
      return
    }
  }

  /** Move downward. If move is unsuccesful, trace is unchanged. */
  private static func moveDownward_F(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)

    let last = trace[trace.endIndex - 1]

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

  /** Move backward until an insertion point. */
  private static func moveBackward(_ trace: inout [TraceElement]) {
    precondition(!trace.isEmpty)

    let last = trace[trace.endIndex - 1]

    switch last.node {
    case let textNode as TextNode:
      let offset = last.index.index()!
      if let destination = textNode.destinationOffset(for: offset, offsetBy: -1) {
        trace[trace.endIndex - 1] = last.with(index: .index(destination))
      }
      else {  // leaving text node, we should move backward again
        trace.popLast()
        moveBackward(&trace)
      }

    case let rootNode as RootNode:
      let index = last.index.index()!
      if rootNode.childCount == 0 {
        return
      }
      else if index == 0 {
        let firstChild = rootNode.getChild(0) as! ElementNode
        trace.append(TraceElement(firstChild, .index(0)))
      }
      else if index == rootNode.childCount {
        let lastIndex = rootNode.childCount - 1
        let lastChild = rootNode.getChild(lastIndex) as! ElementNode
        trace[trace.endIndex - 1] = last.with(index: .index(lastIndex))
        trace.append(TraceElement(lastChild, .index(lastChild.childCount)))
      }
      else {
        let newIndex = index - 1
        trace[trace.endIndex - 1] = last.with(index: .index(newIndex))
        let child = rootNode.getChild(newIndex) as! ElementNode
        trace.append(TraceElement(child, .index(child.childCount)))
      }

    case let elementNode as ElementNode:
      let index = last.index.index()!

      if index == 0 {
        trace.popLast()
        moveBackward(&trace)
      }
      else {
        let newIndex = index - 1
        trace[trace.endIndex - 1] = last.with(index: .index(newIndex))
        // if move downward fails, trace is unchanged
        _ = moveDownward_B(&trace)
      }

    case let applyNode as ApplyNode:
      let index = last.index.argumentIndex()!
      if index == 0 {
        trace.popLast()
      }
      else {
        let newIndex = index - 1
        trace[trace.endIndex - 1] = last.with(index: .argumentIndex(newIndex))
        let child = applyNode.getArgument(newIndex)
        trace.append(TraceElement(child, .index(child.childCount)))
      }

    case let argumentNode as ArgumentNode:
      let index = last.index.index()!
      if index == 0 {
        trace.popLast()
        moveBackward(&trace)
      }
      else {
        let newIndex = index - 1
        trace[trace.endIndex - 1] = last.with(index: .index(newIndex))
        // if move downward fails, trace is unchanged
        _ = moveDownward_B(&trace)
      }

    case let mathNode as MathNode:
      let index = last.index.mathIndex()!
      if let newIndex = mathNode.destinationIndex(for: index, .backward) {
        trace[trace.endIndex - 1] = last.with(index: .mathIndex(newIndex))
        let component = mathNode.getComponent(newIndex)!
        trace.append(TraceElement(component, .index(component.childCount)))
      }
      else {
        trace.popLast()
      }

    default:
      assertionFailure("Unexpected node type")
      return
    }
  }

  /** Move downward. If move is unsuccesful, trace is unchanged. */
  private static func moveDownward_B(_ trace: inout [TraceElement]) -> Bool {
    precondition(!trace.isEmpty)

    let last = trace[trace.endIndex - 1]

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

  /** Returns true if insertion point is allowed immediately within the node. */
  static func isCursorAllowed(_ node: Node) -> Bool {
    node is ArgumentNode || node is ElementNode || node is TextNode
  }
}
