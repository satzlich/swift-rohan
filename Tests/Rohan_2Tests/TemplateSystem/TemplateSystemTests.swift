// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct SystemTemplateTests {
    static let square = TemplateSamples.square
    static let circle = TemplateSamples.circle
    static let ellipse = TemplateSamples.ellipse
    static let cdots = TemplateSamples.cdots
    static let SOS = TemplateSamples.SOS

    @Test
    static func testSystemTemplate() {
        let templates = [circle, ellipse, square, cdots, SOS] as [Template]
        _ = TemplateSystem(templates)
    }
}
