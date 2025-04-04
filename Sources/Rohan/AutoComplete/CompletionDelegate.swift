// Copyright 2024-2025 Lie Yan

protocol CompletionDelegate: AnyObject {
  associatedtype Result
  func completionsDidUpdate(_ results: [Result])
  func completionsFailed(error: Error)
}
