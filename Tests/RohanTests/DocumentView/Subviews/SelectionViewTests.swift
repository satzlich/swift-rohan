// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

@MainActor
struct SelectionViewTests {
  @Test
  func coverage() {
    let selectionView = SelectionView()

    let highlights: Array<HighlightType> = [
      .selection,
      .selection,
      .delimiter(level: 1),
      .delimiter(level: 2),
    ]

    let frames: Array<CGRect> = [
      .zero,
      CGRect(x: 0, y: 0, width: 10, height: 10),
      CGRect(x: 10, y: 10, width: 20, height: 20),
      CGRect(x: 30, y: 30, width: 30, height: 30),
    ]

    assert(highlights.count == frames.count)
    for (highlight, frame) in zip(highlights, frames) {
      selectionView.addHighlightFrame(frame, type: highlight)
    }
    selectionView.clearHighlightFrames()
  }
}
