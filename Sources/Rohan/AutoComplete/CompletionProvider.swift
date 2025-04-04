// Copyright 2024-2025 Lie Yan

protocol CompletionProvider: AnyObject {
  associatedtype Result
  func provideCompletions(for query: String, maxResults: Int) async -> [Result]
}
