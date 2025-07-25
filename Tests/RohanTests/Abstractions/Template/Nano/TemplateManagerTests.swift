import Foundation
import Testing

@testable import SwiftRohan

struct TemplateManagerTests {
  nonisolated(unsafe) static let square = TemplateSamples.square
  nonisolated(unsafe) static let circle = TemplateSamples.circle
  nonisolated(unsafe) static let ellipse = TemplateSamples.ellipse
  nonisolated(unsafe) static let cdots = TemplateSamples.cdots
  nonisolated(unsafe) static let SOS = TemplateSamples.SOS

  @Test
  static func testTemplateManager() {
    let templates = [circle, ellipse, square, cdots, SOS] as Array<Template>
    _ = TemplateManager(templates)
  }
}
