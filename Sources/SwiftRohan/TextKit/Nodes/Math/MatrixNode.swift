// Copyright 2024-2025 Lie Yan

import Foundation

final class MatrixNode: Node {
  override class var type: NodeType { .matrix }

  typealias Row = MatrixRow<MatrixElement>

  private(set) var rows: [Row] = []

  // MARK: - Matrix Element

  final class MatrixElement: ContentNode {
    override func deepCopy() -> MatrixElement { MatrixElement(deepCopyOf: self) }

    override func cloneEmpty() -> Self { Self() }

    override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
      if _cachedProperties == nil {
        var properties = super.getProperties(styleSheet)

        // set math style ← matrix style
        let key = MathProperty.style
        let value = resolveProperty(key, styleSheet).mathStyle()!
        properties[key] = .mathStyle(MathUtils.matrixStyle(for: value))

        _cachedProperties = properties
      }
      return _cachedProperties!
    }
  }
}
