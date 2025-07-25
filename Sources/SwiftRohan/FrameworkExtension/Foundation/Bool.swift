import Foundation

extension Bool {
  @inlinable @inline(__always)
  var intValue: Int { self ? 1 : 0 }
}
