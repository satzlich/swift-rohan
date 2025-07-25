import Testing

@testable import SwiftRohan

struct EditResultTests {
  @Test
  func coverage() {
    let results: Array<EditResult<Int>> = [
      .success(9),
      .extraParagraph(10),
      .failure(SatzError(.InsertStringFailure)),
    ]

    for result in results {
      _ = result.isSuccess
      _ = result.isFailure
      _ = result.success()
      _ = result.failure()
      _ = result.isInternalError
      _ = result.map { $0 * 2 }
    }
  }
}
