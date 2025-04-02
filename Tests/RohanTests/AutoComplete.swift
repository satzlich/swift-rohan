// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

@testable import Rohan

protocol CompletionProvider {
  func provideCompletions(_ context: CompletionContext) -> Array<CompletionItem>
}

enum TriggerKind {
  case auto
  case explicit
  case triggerCharacter(Character)
}

protocol CompletionContext {
  var position: TextLocation { get }
  var triggerKind: TriggerKind { get }
  var editor: EditorInterface { get }
}

protocol CompletionItem {
}

typealias Direction = TextSelectionNavigation.Direction

protocol SuggestionUI {
  func show(items: Array<CompletionItem>, selectedIndex: Int?)
  func hide()
  func moveSelection(_ direction: Direction)
  func getSelectedItem() -> Optional<CompletionItem>
  func confirmSelection()
}

protocol EditorInterface {
  typealias UnregisterClosure = () -> Void

  func registerProvider(_ provider: CompletionProvider) -> UnregisterClosure
  func triggerCompletion(_ context: CompletionContext)

  func showSuggestions(_ suggestions: [CompletionItem])
  func hideSuggestions()

  func getCursorPosition() -> Optional<TextLocation>
  func getWordAtPosition(_ position: TextLocation) -> Optional<(String, RhTextRange)>
  func getTextBeforeCursor(_ n: Int?) -> String
}
