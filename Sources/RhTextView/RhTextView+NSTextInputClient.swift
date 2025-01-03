// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import SatzPointless

extension RhTextView: NSTextInputClient {
    // MARK: - Insertion

    public func insertText(_ string: Any, replacementRange: NSRange) {
        // unmark
        unmarkText()

        // form replacement range
        var replacementRange: NSRange = replacementRange
        if replacementRange.location == NSNotFound { // fix replacementRange
            let success: ()? = textLayoutManager.textSelections.last?.textRanges.last
                .map { textContentManager.characterRange(for: $0) }
                .map { replacementRange = $0 }

            if success == nil {
                return
            }
        }

        // perform edit
        _textContentStorage.textStorage.map { textStorage in
            switch string {
            case let string as String:
                textStorage.replaceCharacters(in: replacementRange, with: string)

            case let attrString as NSAttributedString:
                textStorage.replaceCharacters(in: replacementRange, with: attrString)

            default:
                preconditionFailure("Expected String or NSAttributedString")
            }
        }
        .unwrap_or_else {
            preconditionFailure("Expected text storage")
        }
    }

    // MARK: - Marked Text

    public func setMarkedText(_ string: Any,
                              selectedRange: NSRange,
                              replacementRange: NSRange)
    {
        // form replacement range
        var replacementRange = replacementRange
        if replacementRange.location == NSNotFound { // fix replacementRange
            if _markedText == nil {
                textLayoutManager.textSelections.last?.textRanges.last
                    .map { textContentManager.characterRange(for: $0) }
                    .map { NSRange(location: $0.location, length: 0) }
                    .map { replacementRange = $0 }
                    .unwrap_or_else {
                        preconditionFailure("Expected last text selection")
                    }
            }
            else {
                replacementRange = NSRange(location: _markedText!.markedRange.location,
                                           length: 0)
                // remove current marked text
                _textContentStorage.textStorage.map { textStorage in
                    textStorage.replaceCharacters(in: _markedText!.markedRange, with: "")
                }
                .unwrap_or_else {
                    preconditionFailure("Expected text storage")
                }
            }
        }

        // form attributed string
        let attrString: NSAttributedString
        switch string {
        case let string as String:
            attrString = NSAttributedString(string: string)
        case let attributedString as NSAttributedString:
            attrString = attributedString
        default:
            preconditionFailure()
        }

        // set marked text
        do {
            let markedRange = NSRange(location: replacementRange.location,
                                      length: attrString.length)
            let selectedRange =
                NSRange(location: replacementRange.location + selectedRange.location,
                        length: selectedRange.length)

            _markedText = RhMarkedText(attrString,
                                       markedRange: markedRange,
                                       selectedRange: selectedRange)
        }

        // perform edit
        _textContentStorage.textStorage.map { textStorage in
            textStorage.replaceCharacters(in: replacementRange, with: attrString)
        }
        .unwrap_or_else {
            preconditionFailure("Expected text storage")
        }
    }

    public func unmarkText() {
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
            : NSRange.notFound
    }

    // MARK: - Selected Range

    public func selectedRange() -> NSRange {
        textLayoutManager.textSelections.last?.textRanges.last
            .flatMap(textContentManager.characterRange(for:))
            ?? NSRange.notFound
    }

    // MARK: - Query Attributed String

    public func attributedSubstring(forProposedRange range: NSRange,
                                    actualRange: NSRangePointer?) -> NSAttributedString?
    {
        range
            .cond_wrap { $0.location != NSNotFound }
            .map {
                let documentRange = textContentManager.characterRange(
                    for: textContentManager.documentRange
                )
                return $0.clamped(to: documentRange)
            }
            .map {
                assert($0.location != NSNotFound)
                // set up actual range
                actualRange?.pointee = $0
                // return attributed string
                return _textContentStorage.textStorage!.attributedSubstring(from: $0)
            }
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
        point
            .pipe(window!.convertPoint(fromScreen:))
            .pipe { contentView.convert($0, from: nil) }
            .pipe {
                textLayoutManager.location(
                    interactingAt: $0,
                    inContainerAt: textLayoutManager.documentRange.location
                )
            }
            .map(textContentManager.characterIndex(for:))
            .unwrap_or(NSNotFound)
    }

    public func firstRect(forCharacterRange range: NSRange,
                          actualRange: NSRangePointer?) -> NSRect
    {
        func convertToScreenRect(_ textRange: NSTextRange) -> NSRect {
            var screenRect = NSRect.zero
            textLayoutManager.enumerateTextSegments(in: textRange,
                                                    type: .standard,
                                                    options: .rangeNotRequired)
            { (_, segmentFrame, _, _) in

                screenRect = segmentFrame
                    .pipe { contentView.convert($0, to: nil) }
                    .pipe(window!.convertToScreen(_:))
                return false // stop
            }
            return screenRect
        }

        return range
            .pipe(textContentManager.textRange(for:))
            .map(convertToScreenRect(_:))
            .unwrap_or(NSRect.zero)
    }
}
