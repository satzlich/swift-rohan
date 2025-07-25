import Foundation

extension UTF16 {
  /// Convert a surrogate pair to a code point
  @inlinable @inline(__always)
  static func combineSurrogates(_ lead: UInt16, _ trail: UInt16) -> UInt32 {
    precondition(isLeadSurrogate(lead) && isTrailSurrogate(trail))
    return (UInt32(lead) - 0xD800) * 0x400 + (UInt32(trail) - 0xDC00) + 0x10000
  }
}
