// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    override public func deleteBackward(_ sender: Any?) {
        delete(direction: .backward,
               destination: .character,
               allowsDecomposition: false)
    }

    override public func deleteWordBackward(_ sender: Any?) {
        delete(direction: .backward,
               destination: .word,
               allowsDecomposition: false)
    }

    private func delete(
        direction: NSTextSelectionNavigation.Direction,
        destination: NSTextSelectionNavigation.Destination,
        allowsDecomposition: Bool
    ) {
        // calculate text ranges
        let textRanges
            = textLayoutManager.textSelections.flatMap { textSelection -> [NSTextRange] in
                textLayoutManager.textSelectionNavigation.deletionRanges(
                    for: textSelection,
                    direction: direction,
                    destination: destination,
                    allowsDecomposition: allowsDecomposition
                )
            }

        if textRanges.isEmpty { return }

        // perform edit
        textContentManager.performEditingTransaction {
            textContentManager.replaceContents(in: textRanges, with: nil)
        }
    }
}
