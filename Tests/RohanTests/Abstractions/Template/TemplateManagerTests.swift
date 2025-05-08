// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct TemplateManagerTests {
  static let square = TemplateSamples.square
  static let circle = TemplateSamples.circle
  static let ellipse = TemplateSamples.ellipse
  static let cdots = TemplateSamples.cdots
  static let SOS = TemplateSamples.SOS

  @Test
  static func testTemplateManager() {
    let templates = [circle, ellipse, square, cdots, SOS] as [Template]
    _ = TemplateManager(templates)
  }
}
