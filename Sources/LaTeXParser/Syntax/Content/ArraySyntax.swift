// Copyright 2024-2025 Lie Yan

import Foundation

public struct ArraySyntax: SyntaxProtocol {
  public typealias Row = Array<StreamSyntax>
  public let rows: Array<Row>
}
