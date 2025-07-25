import Testing

@testable import SwiftRohan

struct FontLoaderTests {
  @Test
  func coverage() {
    // normal path
    do {
      let errors = FontLoader.registerFonts()
      #expect(errors.isEmpty, "Font registration errors: \(errors)")
    }

    // invalid file name
    do {
      let errors = FontLoader.registerFonts(["InvalidFontName"])
      guard errors.count == 1,
        let error = errors.first,
        case .invalidFileName = error
      else {
        Issue.record("Expected one error for invalid font file name, got \(errors.count)")
        return
      }
      _ = error.errorDescription
    }
    // font file not found
    do {
      let errors = FontLoader.registerFonts(["NonExistentFontName.otf"])
      guard errors.count == 1,
        let error = errors.first,
        case .fontFileNotFound = error
      else {
        Issue.record("Expected one error for non-existent font file, got \(errors.count)")
        return
      }
      _ = error.errorDescription
    }
    // registration failure
    do {
      let errors = FontLoader.registerFonts(["atop.pdf"])
      guard errors.count == 1,
        let error = errors.first,
        case .registrationFailed = error
      else {
        Issue.record("Expected one error for registration failure, got \(errors.count)")
        return
      }
      _ = error.errorDescription
    }
  }
}
