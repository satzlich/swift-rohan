// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ResultTests {
  @Test
  func coverage() {
    let results: Array<Result<Int, Error>> = [
      .success(1),
      .failure(NSError(domain: "TestError", code: 1, userInfo: nil)),
    ]

    for result in results {
      _ = result.isSuccess
      _ = result.isFailure
      _ = result.success()
      _ = result.failure()
    }
  }
}
