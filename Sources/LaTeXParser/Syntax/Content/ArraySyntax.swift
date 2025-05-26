// Copyright 2024-2025 Lie Yan

import Foundation

public struct ArraySyntax: SyntaxProtocol {
  public typealias Row = Array<WrappedContentSyntax>
  public let rows: Array<Row>
}
