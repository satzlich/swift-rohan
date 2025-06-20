// Copyright 2024-2025 Lie Yan

/// Count holder which does not produce or change any count value and is used as
/// a link in the chain of count holders.
final class VoidCountHolder: CountHolder {
  final override var isActive: Bool { false }

  final override func value(forName name: CounterName) -> Int {
    previousActive?.value(forName: name) ?? 0
  }
}
