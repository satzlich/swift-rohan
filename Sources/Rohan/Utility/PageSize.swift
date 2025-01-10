// Copyright 2024-2025 Lie Yan

import CoreGraphics

public struct PageSize {
    let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public init(width: CGFloat, height: CGFloat) {
        self.size = .init(width: width, height: height)
    }

    public var portrait: CGSize { size }
    public var landscape: CGSize { .init(width: size.height, height: size.width) }

    public static let A4 = PageSize(width: 595, height: 842)
    public static let A5 = PageSize(width: 420, height: 595)
    public static let A6 = PageSize(width: 298, height: 420)
}
