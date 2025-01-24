// Copyright 2024-2025 Lie Yan

import AppKit

public class TextSelectionNavigation {
    public typealias Direction = NSTextSelectionNavigation.Direction
    public enum Destination { case character; case word }
    public struct Modifier: OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let extend: Modifier = {
            let rawValue = NSTextSelectionNavigation.Modifier.extend.rawValue
            return .init(rawValue: rawValue)
        }()

        internal var nsModifier: NSTextSelectionNavigation.Modifier {
            return .init(rawValue: rawValue)
        }
    }

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
        inContainerAt containerLocation: any RhTextLocation,
        anchors: [RhTextSelection],
        modifiers: Modifier,
        selecting: Bool,
        bounds: CGRect
    ) -> [RhTextSelection] {
        preconditionFailure()
    }
}
