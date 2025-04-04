// Copyright 2024-2025 Lie Yan

import Foundation

struct CompletionResult<Value>: CustomStringConvertible {
  let key: String
  let value: Value
  let matchType: MatchType

  enum MatchType: CustomStringConvertible {
    case prefix  // Highest priority
    case ngram  // Middle priority
    case subsequence  // Fallback

    var description: String {
      switch self {
      case .prefix: "prefix"
      case .ngram: "ngram"
      case .subsequence: "subsequence"
      }
    }
  }

  var description: String {
    "(\(key), \(value), \(matchType))"
  }
}
