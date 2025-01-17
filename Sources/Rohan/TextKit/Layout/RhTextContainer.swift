// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class RhTextContainer {
    internal var nsTextContainer: NSTextContainer

    public var size: CGSize { nsTextContainer.size }

    public init() {
        self.nsTextContainer = .init()
    }

    public init(size: CGSize) {
        self.nsTextContainer = .init(size: size)
    }
}
