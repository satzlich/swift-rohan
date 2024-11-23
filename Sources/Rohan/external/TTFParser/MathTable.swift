// Copyright 2024 Lie Yan

import Foundation
import TTFParser

/**
 A safe wrapper of `TTFParser.MathTable`.

 */
struct MathTable {
    let _ttfTable: TTFParser.MathTable
    let _data: CFData

    init?(_ data: CFData) {
        let bytes = UnsafeBufferPointer(start: CFDataGetBytePtr(data),
                                        count: CFDataGetLength(data))

        guard let ttfTable = TTFParser.MathTable.decode(bytes) else {
            return nil
        }

        self._ttfTable = ttfTable
        self._data = data
    }

    var constants: TTFParser.MathConstantsTable? {
        _ttfTable.constants
    }

    var glyphInfo: TTFParser.MathGlyphInfoTable? {
        _ttfTable.glyphInfo
    }

    var variants: TTFParser.MathVariantsTable? {
        _ttfTable.variants
    }
}
