// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

public enum FontLoader {
  public enum FontLoadingError: Error {
    case invalidFileName(String)
    case fontFileNotFound(String)
    case registrationFailed(String, String)
  }

  public static func registerFonts() -> Array<FontLoadingError> {
    var errors = Array<FontLoadingError>()

    for font in allFonts {
      let parts = font.split(separator: ".", maxSplits: 1).map(String.init)
      guard parts.count == 2 else {
        errors.append(.invalidFileName(font))
        continue
      }
      if let error = _registerFont(named: parts[0], extension: parts[1]) {
        errors.append(error)
      }
    }

    return errors
  }

  private static func _registerFont(
    named name: String, extension extensionName: String
  ) -> FontLoadingError? {
    guard let fontURL = Bundle.module.url(forResource: name, withExtension: extensionName)
    else {
      return .fontFileNotFound(name + "." + extensionName)
    }

    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
      let errorDescription =
        error?.takeUnretainedValue().localizedDescription ?? "Unknown error"
      return .registrationFailed(name + "." + extensionName, errorDescription)
    }

    return nil
  }

  static let allFonts: Array<String> = _allFonts()

  private static func _allFonts() -> Array<String> {
    let ConcreteMath: Array<String> = [
      // "NonExistent.otf",
      "Concrete-Math.otf",
      "Concrete-Math-Bold.otf",
    ]
    let CMUConcrete: Array<String> = [
      "cmunobi.ttf", "cmunobx.ttf", "cmunorm.ttf", "cmunoti.ttf",
    ]

    let Libertinus: Array<String> = [
      "LibertinusMath-Regular.otf",
      "LibertinusMono-Regular.otf",
      "LibertinusSans-Bold.otf",
      "LibertinusSans-Italic.otf",
      "LibertinusSans-Regular.otf",
      "LibertinusSerif-Bold.otf",
      "LibertinusSerif-BoldItalic.otf",
      "LibertinusSerif-Italic.otf",
      "LibertinusSerif-Regular.otf",
    ]

    let Noto: Array<String> = [
      "NotoSans-Bold.ttf",
      "NotoSans-BoldItalic.ttf",
      "NotoSans-Italic.ttf",
      "NotoSans-Regular.ttf",
      "NotoSerif-Bold.ttf",
      "NotoSerif-BoldItalic.ttf",
      "NotoSerif-Italic.ttf",
      "NotoSerif-Regular.ttf",
      "NotoSansMath-Regular.ttf",
    ]

    let NewComputerModern: Array<String> = [
      "NewCM10-Bold.otf",
      "NewCM10-BoldItalic.otf",
      "NewCM10-Italic.otf",
      "NewCM10-Regular.otf",
      "NewCMMath-Bold.otf",
      "NewCMMath-Regular.otf",
      "NewCMMono10-Bold.otf",
      "NewCMMono10-BoldOblique.otf",
      "NewCMMono10-Italic.otf",
      "NewCMMono10-Regular.otf",
      "NewCMSans10-Bold.otf",
      "NewCMSans10-BoldOblique.otf",
      "NewCMSans10-Oblique.otf",
      "NewCMSans10-Regular.otf",
      "NewCMSansMath-Regular.otf",
    ]

    let STIX: Array<String> = [
      "STIXTwoMath-Regular.otf",
      "STIXTwoText-Bold.otf",
      "STIXTwoText-BoldItalic.otf",
      "STIXTwoText-Italic.otf",
      "STIXTwoText-Regular.otf",
    ]

    return ConcreteMath + CMUConcrete + Libertinus + Noto + NewComputerModern + STIX
  }
}

extension FontLoader.FontLoadingError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidFileName(let name):
      return "Invalid font file name: \(name)"
    case .fontFileNotFound(let name):
      return "Font file not found: \(name)"
    case .registrationFailed(let name, let error):
      return "Failed to register font \(name): \(error)"
    }
  }
}
