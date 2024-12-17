// Copyright 2024 Lie Yan

import Foundation
import TTFParser

/**
 A **memory-safe** wrapper of `TTFParser.MathTable`.

 */
struct MathTable {
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

    var constants: TTFParser.MathConstantsTable? {
        ttfTable.constants
    }

    var glyphInfo: TTFParser.MathGlyphInfoTable? {
        ttfTable.glyphInfo
    }

    var variants: TTFParser.MathVariantsTable? {
        ttfTable.variants
    }
}
