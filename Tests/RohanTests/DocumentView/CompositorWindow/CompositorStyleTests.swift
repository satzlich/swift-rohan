import Testing

@testable import SwiftRohan

struct CompositorStyleTests {
  @Test
  func coverage() {
    _ = CompositorStyle.previewAttrs(mathMode: true)
    _ = CompositorStyle.previewAttrs(mathMode: false)
  }
}
