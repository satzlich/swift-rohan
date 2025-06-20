// Copyright 2024-2025 Lie Yan

/// Initial count holder which is placed at the beginning of the linked list.
final class InitialCountHolder: CountHolder {

  final override var isDirty: Bool { false }

  final override func propagateDirty() { next?.propagateDirty() }

  final override func value(forName name: CounterName) -> Int {
    0 /* always "0" */
  }
}
