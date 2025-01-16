// Copyright 2024-2025 Lie Yan

extension RhTextLayoutManager {
    var documentRange: RhTextRange { preconditionFailure() }
    var textSelections: [RhTextSelection] {
        get { preconditionFailure() }
        set { preconditionFailure() }
    }

    var textSelectionNavigation: RhTextSelectionNavigation { preconditionFailure() }

    func ensureLayout(for range: RhTextRange) { preconditionFailure() }
}
