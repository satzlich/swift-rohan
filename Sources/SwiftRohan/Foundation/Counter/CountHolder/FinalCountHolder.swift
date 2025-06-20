// Copyright 2024-2025 Lie Yan

/// Final count holder which is placed at the end of the linked list.
final class FinalCountHolder: CountHolder {

  final override var isActive: Bool { true }

  final override func value(forName name: CounterName) -> Int {
    previousActive?.value(forName: name) ?? 0
  }
}
