// Copyright 2024-2025 Lie Yan

import AppKit

public class TextSelectionNavigation {
    public typealias Direction = NSTextSelectionNavigation.Direction
    public typealias Destination = NSTextSelectionNavigation.Destination
    public typealias Modifier = NSTextSelectionNavigation.Modifier

    public func destinationSelection(
        for: RhTextSelection,
        direction: Direction,
        destination: Destination,
        extending: Bool,
        confined: Bool
    ) -> RhTextSelection? {
        preconditionFailure()
    }

    public func deletionRanges(
        for textSelection: RhTextSelection,
        direction: Direction,
        destination: Destination,
        allowsDecomposition: Bool
    ) -> [RhTextRange] {
        preconditionFailure()
    }

    public func textSelections(
        interactingAt point: CGPoint,
        inContainerAt containerLocation: any TextLocation,
        anchors: [RhTextSelection],
        modifiers: Modifier,
        selecting: Bool,
        bounds: CGRect
    ) -> [RhTextSelection] {
        preconditionFailure()
    }
}
