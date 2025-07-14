// Copyright 2024-2025 Lie Yan

enum TheoremSubtype: String {
  case theorem
  case lemma
  case corollary
  case observation
  case definition
  case remark
  case proof
}

extension TheoremSubtype {
  func createCountHolder() -> CountHolder? {
    _counterName.map { CountHolder($0) }
  }

  func formatTitle(_ counter: CountHolder?) -> String {
    switch self {
    case .theorem:
      guard let number = counter?.value(forName: .theorem)
      else { return "Theorem " }
      return "Theorem \(number) "

    case .corollary:
      guard let number = counter?.value(forName: .theorem)
      else { return "Corollary " }
      return "Corollary \(number) "

    case .lemma:
      guard let number = counter?.value(forName: .theorem)
      else { return "Lemma. " }
      return "Lemma \(number) "

    case .observation:
      guard let number = counter?.value(forName: .theorem)
      else { return "Observation. " }
      return "Observation \(number) "

    case .definition:
      guard let number = counter?.value(forName: .theorem)
      else { return "Definition. " }
      return "Definition \(number) "

    case .remark:
      return "Remark. "

    case .proof:
      return "Proof. "
    }
  }

  internal var _counterName: CounterName? {
    switch self {
    case .theorem: return .theorem
    case .lemma: return .theorem
    case .corollary: return .theorem
    case .observation: return .theorem
    case .definition: return .theorem
    case .remark: return nil
    case .proof: return nil
    }
  }
}

extension TheoremSubtype {
  var command: String { self.rawValue }
}
