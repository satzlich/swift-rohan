// Copyright 2024 Lie Yan

import CoreGraphics
import Foundation

extension CGRect {
    var pixelAligned: CGRect {
        /*
         https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/APIs/APIs.html#//apple_ref/doc/uid/TP40012302-CH5-SW9
         */
        #if os(macOS) && !targetEnvironment(macCatalyst)
        NSIntegralRectWithOptions(self, AlignmentOptions.alignAllEdgesNearest)
        #elseif os(iOS) || targetEnvironment(macCatalyst)
        NSIntegralRectWithOptions(self, AlignmentOptions.alignAllEdgesNearest)
        #endif
    }
}
