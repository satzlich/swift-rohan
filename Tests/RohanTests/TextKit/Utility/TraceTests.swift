// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TraceTests {
  @Test
  func emptyRoot() {
    let rootNode = RootNode()
    let location = TextLocation.parse("[]:0")!
    guard var trace = Trace.from(location, rootNode)
    else {
      Issue.record("Failed to create trace from empty root node")
      return
    }
    for _ in 0..<10 {
      trace.moveForward()
    }
    #expect("\(trace.toNormalLocation()!)" == "[]:0")
    for _ in 0..<10 {
      trace.moveBackward()
    }
    #expect("\(trace.toNormalLocation()!)" == "[]:0")

    //
    _ = trace.toRawLocation()
  }

  @Test
  func emptyElement() {
    let rootNode = RootNode([
      ParagraphNode([])
    ])

    //
    do {
      let location = TextLocation.parse("[↓0]:0")!
      guard var trace = Trace.from(location, rootNode)
      else {
        Issue.record("Failed to create trace from empty element")
        return
      }

      for _ in 0..<10 {
        trace.moveForward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[↓0]:0")
      for _ in 0..<10 {
        trace.moveBackward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[↓0]:0")
    }
    do {
      let location = TextLocation.parse("[]:1")!
      guard var trace = Trace.from(location, rootNode)
      else {
        Issue.record("Failed to create trace from empty element")
        return
      }

      for _ in 0..<10 {
        trace.moveForward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[↓0]:0")
      for _ in 0..<10 {
        trace.moveBackward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[↓0]:0")
    }
  }

  @Test
  func rootNodeWithEquation() {
    let rootNode = RootNode([
      EquationNode(.block, [TextNode("x")])
    ])
    do {
      let location = TextLocation.parse("[]:1")!
      guard var trace = Trace.from(location, rootNode)
      else {
        Issue.record("Failed to create trace from root node with equation")
        return
      }

      for _ in 0..<10 {
        trace.moveForward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[]:1")
      for _ in 0..<10 {
        trace.moveBackward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[]:0")
    }
  }

  @Test
  func matrix() {
    let rootNode = RootNode([
      EquationNode(
        .block,
        [
          MatrixNode(
            .pmatrix,
            [
              [ContentNode([TextNode("1")]), ContentNode([TextNode("2")])],
              [ContentNode([TextNode("3")]), ContentNode([TextNode("4")])],
            ])
        ])
    ])
    do {
      let location = TextLocation.parse("[]:0")!
      guard var trace = Trace.from(location, rootNode)
      else {
        Issue.record("Failed to create trace from matrix node")
        return
      }

      for _ in 0..<20 {
        trace.moveForward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[]:1")
      for _ in 0..<20 {
        trace.moveBackward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[]:0")
    }
  }

  @Test
  func applyNodeWithMultipleArguments() {
    let rootNode = RootNode([
      EquationNode(
        .block,
        [
          ApplyNode(
            MathTemplate.stackrel,
            [
              [TextNode("def")],
              [
                NamedSymbolNode(.lookup("rightarrow")!),
                NamedSymbolNode(.lookup("rightarrow")!),
              ],
            ])!
        ])
    ])
    do {
      let location = TextLocation.parse("[]:0")!
      guard var trace = Trace.from(location, rootNode)
      else {
        Issue.record("Failed to create trace from apply node with multiple arguments")
        return
      }

      for _ in 0..<20 {
        trace.moveForward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[]:1")

      for _ in 0..<20 {
        trace.moveBackward()
      }
      #expect("\(trace.toNormalLocation()!)" == "[]:0")
    }
  }

}
