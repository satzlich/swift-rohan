// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class RhTextContentStorage: NSTextContentStorage {
    override func replaceContents(in range: NSTextRange,
                                  with textElements: [NSTextElement]?)
    {
        precondition(hasEditingTransaction,
                     "Cannot call replaceContents without an editing transaction")

        guard let textStorage = textStorage,
              let textElements = textElements
        else {
            // Non-functional (FB9925647)
            super.replaceContents(in: range, with: textElements)
            assertionFailure()
            return
        }

        // compose a single attributed string
        let replacementString = NSMutableAttributedString()
        replacementString.beginEditing()
        textElements
            .compactMap { self.attributedString(for: $0) }
            .reduce(into: replacementString) { result, attrString in
                result.append(attrString)
            }
        replacementString.endEditing()

        // replace
        textStorage.beginEditing()
        textStorage.replaceCharacters(in: characterRange(for: range),
                                      with: replacementString)
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
