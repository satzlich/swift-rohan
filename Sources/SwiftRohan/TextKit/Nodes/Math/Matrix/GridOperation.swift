// Copyright 2024-2025 Lie Yan

internal enum GridOperation {
  case insertRow(at: Int)
  case insertColumn(at: Int)

  case removeRow(at: Int)
  case removeColumn(at: Int)
}
