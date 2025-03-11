// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView: @preconcurrency NSTextInputClient {
    // MARK: - Insertion

    public func insertText(_ string: Any, replacementRange: NSRange) {
        // unmark
        unmarkText()

        // form replacement range
        var replacementRange: NSRange = replacementRange
        if replacementRange.location == NSNotFound { // fix replacementRange
            guard textLayoutManager.textSelections.count == 1,
                  let textSelection = textLayoutManager.textSelections.first,
                  textSelection.textRanges.count == 1,
                  let textRange = textSelection.textRanges.first
            else { return }

            replacementRange = textContentManager.characterRange(for: textRange)
        }

        assert(_textContentStorage.textStorage != nil)
        let textStorage = _textContentStorage.textStorage!

        // set up undo (DUMMY)
        undoManager?.beginUndoGrouping()
        undoManager?.registerUndo(withTarget: self, handler: { textView in
            // TODO: implement
        })
        undoManager?.endUndoGrouping()

        // perform edit
        switch string {
        case let string as String:
            textStorage.replaceCharacters(in: replacementRange, with: string)
        case let attributedString as NSAttributedString:
            textStorage.replaceCharacters(in: replacementRange, with: attributedString)
        default:
            preconditionFailure()
        }
    }

    // MARK: - Marked Text

    public func setMarkedText(_ string: Any,
                              selectedRange: NSRange,
                              replacementRange: NSRange)
    {
        precondition(_textContentStorage.textStorage != nil)
        let textStorage = _textContentStorage.textStorage!

        // form replacement range
        var replacementRange = replacementRange
        if replacementRange.location == NSNotFound { // fix replacementRange
            if _markedText == nil {
                guard textLayoutManager.textSelections.count == 1,
                      let textSelection = textLayoutManager.textSelections.first,
                      textSelection.textRanges.count == 1,
                      let textRange = textSelection.textRanges.first
                else { return }

                let location = textContentManager.characterRange(for: textRange).location
                // set replacement range
                replacementRange = NSRange(location: location, length: 0)
            }
            else {
                let markedRange = _markedText!.markedRange
                // set replacement range
                replacementRange = NSRange(location: markedRange.location, length: 0)
                // remove current marked text
                textStorage.replaceCharacters(in: markedRange, with: "")
            }
        }

        // form marked text
        let attrString: NSAttributedString
        switch string {
        case let string as String:
            attrString = NSAttributedString(string: string)
        case let attributedString as NSAttributedString:
            attrString = attributedString
        default:
            preconditionFailure()
        }

        // perform edit
        textStorage.replaceCharacters(in: replacementRange, with: attrString)

        // set marked text
        let markedRange = NSRange(location: replacementRange.location,
                                  length: attrString.length)
        let selectedRange = NSRange(location: replacementRange.location + selectedRange.location,
                                    length: selectedRange.length)
        _markedText = RhMarkedText(attrString,
                                   markedRange: markedRange,
                                   selectedRange: selectedRange)

        // update selection
        let textRange = textContentManager.textRange(for: selectedRange)
        if textRange != nil {
            textLayoutManager.textSelections = [
                NSTextSelection(range: textRange!,
                                affinity: .downstream,
                                granularity: .character),
            ]
        }

        // log marked text
        if DebugConfig.LOG_MARKED_TEXT {
            logger.debug("\(self._markedText!.debugDescription)")
        }
    }

    public func unmarkText() {
        precondition(_textContentStorage.textStorage != nil)

        if hasMarkedText() {
            _textContentStorage.textStorage!.deleteCharacters(in: _markedText!.markedRange)
        }
        _markedText = nil
    }

    public func hasMarkedText() -> Bool {
        _markedText != nil
    }

    public func markedRange() -> NSRange {
        hasMarkedText()
            ? _markedText!.markedRange
            : NSRange(location: NSNotFound, length: 0)
    }

    // MARK: - Selected Range

    public func selectedRange() -> NSRange {
        guard textLayoutManager.textSelections.count == 1,
              let textSelection = textLayoutManager.textSelections.first,
              textSelection.textRanges.count == 1,
              let textRange = textSelection.textRanges.first
        else { return NSRange(location: NSNotFound, length: 0) }

        return textContentManager.characterRange(for: textRange)
    }

    // MARK: - Query Attributed String

    public func attributedSubstring(
        forProposedRange range: NSRange,
        actualRange: NSRangePointer?
    ) -> NSAttributedString? {
        guard range.location != NSNotFound else { return nil }

        // clamp range
        let documentRange = textContentManager.characterRange(for: textContentManager.documentRange)
        let range = range.clamped(to: documentRange)

        assert(range.location != NSNotFound)
        // set up actual range
        actualRange?.pointee = range
        // return attributed string
        assert(_textContentStorage.textStorage != nil)
        return _textContentStorage.textStorage!.attributedSubstring(from: range)
    }

    public func validAttributesForMarkedText() -> [NSAttributedString.Key] {
        [
            .underlineColor,
            .underlineStyle,
            .markedClauseSegment,
        ]
    }

    // MARK: - Query Index / Coordinate

    public func characterIndex(for point: NSPoint) -> Int {
        let windowPoint = window!.convertPoint(fromScreen: point)
        let point = contentView.convert(windowPoint, from: nil)
        let location = textLayoutManager.location(
            interactingAt: point,
            inContainerAt: textLayoutManager.documentRange.location
        )

        return location != nil
            ? textContentManager.characterIndex(for: location!)
            : NSNotFound
    }

    public func firstRect(forCharacterRange range: NSRange,
                          actualRange: NSRangePointer?) -> NSRect
    {
        func convertToScreenRect(_ textRange: NSTextRange) -> NSRect {
            var screenRect = NSRect.zero
            textLayoutManager.enumerateTextSegments(in: textRange,
                                                    type: .standard,
                                                    options: .rangeNotRequired)
            { (_, textSegmentFrame, _, _) in

                let viewRect = contentView.convert(textSegmentFrame, to: nil)
                screenRect = window!.convertToScreen(viewRect)
                return false // stop
            }
            return screenRect
        }

        let textRange = textContentManager.textRange(for: range)
        return textRange != nil
            ? convertToScreenRect(textRange!)
            : NSRect.zero
    }
}
