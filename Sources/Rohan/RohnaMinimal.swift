// Copyright 2024-2025 Lie Yan

import Foundation
@_exported import RohanCommon

extension String {
    /// Returns the NSString length
    public func lengthAsNSString() -> Int { (self as NSString).length }
}
