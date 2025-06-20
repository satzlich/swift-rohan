// Copyright 2024-2025 Lie Yan

final class BasicCountHolder: CountHolder {
  final override var isActive: Bool { true }

  final override func value(forName name: CounterName) -> Int {
    preconditionFailure()
  }

  final func computeValue(forName name: CounterName) -> Int {
    switch name {
    case .section:
      let previousValue = previousActive?.value(forName: .section) ?? 0
      switch self.name {
      case .section: return previousValue + 1
      case _: return previousValue
      }

    case .subsection:
      switch self.name {
      case .section:
        return 0
      case .subsection:
        let previousValue = previousActive?.value(forName: .subsection) ?? 0
        return previousValue + 1
      case _:
        let previousValue = previousActive?.value(forName: .subsection) ?? 0
        return previousValue
      }

    case .subsubsection:
      switch self.name {
      case .section, .subsection:
        return 0
      case .subsubsection:
        let previousValue = previousActive?.value(forName: .subsubsection) ?? 0
        return previousValue + 1
      case _:
        let previousValue = previousActive?.value(forName: .subsubsection) ?? 0
        return previousValue
      }

    case .equation:
      let previousValue = previousActive?.value(forName: .equation) ?? 0
      switch self.name {
      case .equation:
        return previousValue + 1
      case _:
        return previousValue
      }
    }
  }

  let name: CounterName

  init(_ name: CounterName) {
    self.name = name
  }
}
