import Foundation
import TTFParser

/// A __memory-safe__ wrapper of `TTFParser.MathTable`.
public struct MathTable {
  @usableFromInline let _table: TTFParser.MathTable
  @usableFromInline let _data: CFData  // Hold reference

  @inlinable
  init?(_ data: CFData) {
    let bytes = CFDataGetBytePtr(data)
    let length = CFDataGetLength(data)
    let buffer = UnsafeBufferPointer(start: bytes, count: length)
    guard let table = TTFParser.MathTable.decode(buffer) else { return nil }

    self._table = table
    self._data = data
  }

  public var constants: TTFParser.MathConstantsTable? { _table.constants }
  public var glyphInfo: TTFParser.MathGlyphInfoTable? { _table.glyphInfo }
  public var variants: TTFParser.MathVariantsTable? { _table.variants }
}
