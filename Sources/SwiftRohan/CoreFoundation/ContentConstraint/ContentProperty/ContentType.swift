import Foundation

enum ContentType: CaseIterable {
  case inline
  case block
}

extension ContentType {
  @inlinable @inline(__always)
  func isCompatible(with container: ContainerType) -> Bool {
    container.isCompatible(with: self)
  }
}
