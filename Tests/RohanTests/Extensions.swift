// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@testable import SwiftRohan

extension CaseIterable {
  /// Returns a set of all cases not in the list.
  static func complementSet<S: Sequence<Self>>(to values: S) -> Set<Self> {
    let allCases: Set<Self> = Set(Self.allCases)
    return allCases.subtracting(values)
  }
}

extension TextLocation {
  static func compose(_ indices: String, _ offset: Int) -> TextLocation? {
    guard let indices = TextLocation.parseIndices(indices)
    else { return nil }
    return TextLocation(indices, offset)
  }
}

extension TextLayoutContext {
  convenience init(_ styleSheet: StyleSheet) {
    let textContentStorage = NSTextContentStoragePatched()
    let textLayoutManager = NSTextLayoutManager()

    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    textLayoutManager.textContainer = NSTextContainer()

    self.init(styleSheet, textContentStorage, textLayoutManager)
  }
}
