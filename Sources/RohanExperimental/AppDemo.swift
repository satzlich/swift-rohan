// Copyright 2024-2025 Lie Yan

@testable import RohanMinimal
import Foundation

enum AppDemo {
    func insertAndUndo(_ text: Text) {
        let contentStorage: RhTextContentStorage = someValue()
        let location: any RhTextLocation = someValue()

        // insert
        contentStorage.replaceContents(in: RhTextRange(location: location),
                                       with: [.text(text)])

        // undo
        let undo: () -> Void = {
            guard let end = contentStorage.location(location, offsetBy: text.string.count),
                  let deleteRange = RhTextRange(location: location, end: end)
            else { fatalError() }
            return {
                contentStorage.replaceContents(in: deleteRange, with: nil)
            }
        }()

        // perform undo
        undo()
    }

    func deleteAndUndo() {
        let contentStorage: RhTextContentStorage = someValue()
        let textRange: RhTextRange = someValue()

        // undo
        let undo: () -> Void = {
            // save deleted nodes
            var deletedContent: [RohanMinimal.Expression] = []
            _ = contentStorage.enumerateSubnodes(in: textRange) { subnode, subnodeRange in
                guard let subnode else { return true }
                deletedContent.append(subnode)
                return true // continue
            }
            // construct insert range
            let insertRange = RhTextRange(location: textRange.location)

            return {
                contentStorage.replaceContents(in: insertRange, with: deletedContent)
            }
        }()

        // delete
        contentStorage.replaceContents(in: textRange, with: nil)

        // perform undo
        undo()
    }

    func reconcileSelection() {
        let textLayoutManager: RhTextLayoutManager = someValue()
        let viewFrame: CGRect = someValue()

        // get text selection
        let textSelections = textLayoutManager.textSelections
        guard textSelections.count == 1 else { fatalError() }
        let textSelection = textSelections[0]

        // produce highlight frames
        var highlightFrames: [CGRect] = []
        for textRange in textSelection.textRanges {
            textLayoutManager.enumerateTextSegments(in: textRange) {
                (textSegment, textSegmentFrame, _) in

                let textSegmentFrame = textSegmentFrame.intersection(viewFrame)
                guard textSegmentFrame.isEmpty else { return true }
                highlightFrames.append(textSegmentFrame)
                return true // continue
            }
        }
    }

    func reconcileInsertionPoint() {
        let textLayoutManager: RhTextLayoutManager = someValue()
        let location: RhTextLocation = someValue()

        // get insertion point
        let textRange = RhTextRange(location: location)
        var insertionPointFrame: CGRect = .zero
        textLayoutManager.enumerateTextSegments(in: textRange) {
            (textSegment, textSegmentFrame, _) in
            guard let textSegment else { return true }
            insertionPointFrame = textSegmentFrame
            return false
        }
        useValue(insertionPointFrame)
    }
}
