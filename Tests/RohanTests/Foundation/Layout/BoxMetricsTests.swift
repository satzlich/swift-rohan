import Foundation
import Testing

@testable import SwiftRohan

struct BoxMetricsTests {
  @Test
  func coverage() {
    let metrics = BoxMetrics(width: 10, ascent: 3, descent: 5)
    let metrics2 = BoxMetrics(width: 10, ascent: 3, descent: 5.00000001)

    #expect(metrics.isNearlyEqual(to: metrics2))
    _ = "\(metrics)"
  }
}
