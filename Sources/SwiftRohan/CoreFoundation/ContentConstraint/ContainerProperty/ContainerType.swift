import Foundation

enum ContainerType: String, Codable, CaseIterable {
  case inline
  case block
  /// can contain inline or block elements
  case mixed
}

extension ContainerType {
  @inlinable @inline(__always)
  func isCompatible(with content: ContentType) -> Bool {
    switch (self, content) {
    case (.inline, .inline): true
    case (.block, _): true  // inline can be converted to paragraph
    case (.mixed, _): true
    case _: false
    }
  }
}
