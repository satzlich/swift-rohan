// Copyright 2024-2025 Lie Yan

import Foundation

public struct ArraySyntax: SyntaxProtocol {
  public typealias Row = Array<StreamSyntax>
  public let rows: Array<Row>

  public init(_ rows: Array<Row>) {
    self.rows = rows
  }
}

extension ArraySyntax {
  public func deparse(_ context: DeparseContext) -> Array<any TokenProtocol> {
    var tokens = Array<any TokenProtocol>()

    for (i, row) in rows.enumerated() {
      if i > 0 {
        tokens.append(EscapedCharToken.backslash)
        tokens.append(NewlineToken())
      }

      for (j, stream) in row.enumerated() {
        if j > 0 {
          tokens.append(SpaceToken())
          tokens.append(AlignmentTabToken())
          tokens.append(SpaceToken())
        }
        tokens.append(contentsOf: stream.deparse(context))
      }
    }
    return tokens
  }
}
