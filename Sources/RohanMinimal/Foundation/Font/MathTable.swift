// Copyright 2024-2025 Lie Yan

import Foundation
import TTFParser

/** A __memory-safe__ wrapper of `TTFParser.MathTable`. */
public struct MathTable {
    private let ttfTable: TTFParser.MathTable
    private let data: CFData // Hold reference

    init?(_ data: CFData) {
        let bytes = UnsafeBufferPointer(start: CFDataGetBytePtr(data),
                                        count: CFDataGetLength(data))

        guard let ttfTable = TTFParser.MathTable.decode(bytes) else {
            return nil
        }

        self.ttfTable = ttfTable
        self.data = data
    }

    public var constants: TTFParser.MathConstantsTable? {
        ttfTable.constants
    }

    public var glyphInfo: TTFParser.MathGlyphInfoTable? {
        ttfTable.glyphInfo
    }

    public var variants: TTFParser.MathVariantsTable? {
        ttfTable.variants
    }
}
