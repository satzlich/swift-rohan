// Copyright 2024-2025 Lie Yan

import Foundation

final class RelayCountHolder: CountHolder {
  final override var isDirty: Bool { previous?.isDirty ?? false }

  final override func propagateDirty() {
    next?.propagateDirty()
  }

  final override func value(forName name: CounterName) -> Int {
    previous?.value(forName: name) ?? 0
  }
}
