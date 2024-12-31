// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import SatzPointless

extension RhTextView: NSTextInputClient {
    // MARK: - Query Attributed String

    public func attributedSubstring(
        forProposedRange range: NSRange,
        actualRange: NSRangePointer?
    ) -> NSAttributedString? {
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

    // MARK: - Marked Text

    public func setMarkedText(_ string: Any,
                              selectedRange: NSRange,
                              replacementRange: NSRange)
    {
        // form replacement range
        var replacement: NSRange
        if replacementRange.location != NSNotFound {
            replacement = replacementRange
        }
        else if markedText == nil {
            let last = textLayoutManager.textSelections.last?.textRanges.last
            guard let last else {
                preconditionFailure("Expected last text selection")
            }
            let s = textContentManager.characterRange(for: last)
            replacement = NSRange(location: s.location, length: 0)
        }
        else {
            _textContentStorage.textStorage!
                .replaceCharacters(in: markedText!.markedRange, with: "")
            replacement = NSRange(location: markedText!.markedRange.location, length: 0)
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
        markedText = RhMarkedText(
            attrString,
            markedRange: NSRange(location: replacement.location, length: attrString.length),
            selectedRange: NSRange(location: replacement.location + selectedRange.location,
                                   length: selectedRange.length)
        )
        
        // perform edit
        _textContentStorage.textStorage!
            .replaceCharacters(in: replacement, with: attrString)
    }

    public func unmarkText() {
        if hasMarkedText() {
            _textContentStorage.textStorage!.deleteCharacters(in: markedText!.markedRange)
        }
        markedText = nil
    }

    public func hasMarkedText() -> Bool {
        markedText != nil
    }

    public func markedRange() -> NSRange {
        hasMarkedText()
            ? markedText!.markedRange
            : NSRange.notFound
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
            textLayoutManager.enumerateTextSegments(
                in: textRange, type: .standard, options: .rangeNotRequired
            ) { (_, segmentFrame, _, _) in

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

    // MARK: - Insertion

    public func insertText(_ string: Any, replacementRange: NSRange) {
        // unmark
        unmarkText()

        // get character range
        var replacementRange: NSRange = replacementRange
        if replacementRange.location == NSNotFound {
            let last = textLayoutManager.textSelections.last?.textRanges.last
            guard let last else { return }
            replacementRange = textContentManager.characterRange(for: last)
        }

        // perform edit
        switch string {
        case let string as String:
            _textContentStorage.textStorage!
                .replaceCharacters(in: replacementRange, with: string)

        case let attributedString as NSAttributedString:
            _textContentStorage.textStorage!
                .replaceCharacters(in: replacementRange, with: attributedString)

        default:
            preconditionFailure()
        }
    }

    // MARK: - Helpers

    public func selectedRange() -> NSRange {
        textLayoutManager.textSelections.last?.textRanges.last
            .flatMap(textContentManager.characterRange(for:))
            ?? NSRange.notFound
    }
}
