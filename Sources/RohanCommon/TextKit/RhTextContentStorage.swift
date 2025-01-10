// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class RhTextContentStorage: NSTextContentStorage {
    override public func replaceContents(in range: NSTextRange,
                                         with textElements: [NSTextElement]?)
    {
        precondition(hasEditingTransaction)

        guard let textStorage = textStorage else {
            // Non-functional (FB9925647)
            super.replaceContents(in: range, with: textElements)
            assertionFailure("Non-functional (FB9925647)")
            return
        }

        // convert to character range
        let characterRange = characterRange(for: range)

        // convert to attributed string
        let replacementString
            = textElements.map(attributedString(for:)) ?? NSAttributedString()

        // replace
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: characterRange, with: replacementString)
        textStorage.endEditing()

        // fix
        fix_fixSelectionAfterChangeInCharacterRange()
    }

    // Fix a result of the NSTextLayoutManager._fixSelectionAfterChangeInCharacterRange
    // specifically: duplicated (identical) ranges and selections
    private func fix_fixSelectionAfterChangeInCharacterRange() {
        // Remove duplicated selections that are result of _fixSelectionAfterChangeInCharacterRange
        for textLayoutManager in textLayoutManagers {
            let origSelections = textLayoutManager.textSelections
            var uniqueSelections: [NSTextSelection] = []
            uniqueSelections.reserveCapacity(origSelections.count)

            // Remove duplicated selections
            for selection in origSelections {
                if !uniqueSelections.contains(where: { $0.textRanges == selection.textRanges }) {
                    uniqueSelections.append(selection)
                }
            }

            // Remove duplicated textRanges in selections
            var finalSelections: [NSTextSelection] = []
            finalSelections.reserveCapacity(uniqueSelections.count)
            for selection in uniqueSelections {
                var uniqueRanges: [NSTextRange] = []
                uniqueRanges.reserveCapacity(selection.textRanges.count)
                for textRange in selection.textRanges {
                    if !uniqueRanges.contains(where: { $0 == textRange }) {
                        uniqueRanges.append(textRange)
                    }
                }

                let selectionCopy = NSTextSelection(
                    uniqueRanges,
                    affinity: selection.affinity,
                    granularity: selection.granularity
                )
                selectionCopy.anchorPositionOffset = selection.anchorPositionOffset
                selectionCopy.isLogical = selection.isLogical
                selectionCopy.typingAttributes = selection.typingAttributes
                finalSelections.append(selectionCopy)
            }

            textLayoutManager.textSelections = finalSelections
        }
    }
}
