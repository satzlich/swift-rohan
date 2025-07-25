import Foundation

enum ContainerMode: CaseIterable {
  case text
  case math
}

extension ContainerMode {
  func layoutMode() -> LayoutMode {
    switch self {
    case .text: .textMode
    case .math: .mathMode
    }
  }
}

extension ContainerMode {
  @inlinable @inline(__always)
  func isCompatible(with content: ContentMode) -> Bool {
    switch (self, content) {
    case (.text, .text): true
    case (.math, .math): true
    case (_, .universal): true
    case _: false
    }
  }
}
