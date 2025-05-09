// Copyright 2024-2025 Lie Yan

internal enum GridOperation {
  case insertRow(_ elements: Array<Array<Node>>, at: Int)
  case insertColumn(_ elements: Array<Array<Node>>, at: Int)
  case removeRow(at: Int)
  case removeColumn(at: Int)

  var isInsertion: Bool {
    switch self {
    case .insertRow, .insertColumn:
      return true
    case .removeRow, .removeColumn:
      return false
    }
  }

  var isRemoval: Bool {
    switch self {
    case .removeRow, .removeColumn:
      return true
    case .insertRow, .insertColumn:
      return false
    }
  }
}
