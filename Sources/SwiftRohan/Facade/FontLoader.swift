// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

public enum FontLoader {
  public static func registerFonts() {
    for font in allFonts {
      let parts = font.split(separator: ".", maxSplits: 1).map(String.init)
      guard parts.count == 2
      else {
        assertionFailure("Invalid font file name: \(font)")
        continue
      }
      let name = parts[0]
      let ext = parts[1]
      registerFont(named: name, extension: ext)
    }
  }

  /// Registers a single font file
  private static func registerFont(
    named name: String, extension extensionName: String
  ) {
    guard
      let fontURL = Bundle.module.url(forResource: name, withExtension: extensionName),
      let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
      let font = CGFont(fontDataProvider)
    else {
      assertionFailure("Failed to load font: \(name)")
      return
    }

    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterGraphicsFont(font, &error) {
      let error = error?.takeUnretainedValue().localizedDescription ?? "Unknown error"
      assertionFailure("Failed to register font: \(name), error: \(error)")
    }
  }

  static let allFonts: Array<String> =
    ConcreteMath + CMUConcrete + Libertinus + Noto + newComputerModern + STIX

  private static let ConcreteMath: Array<String> = [
    "Concrete-Math.otf",
    "Concrete-Math-Bold.otf",
  ]

  private static let CMUConcrete: Array<String> = [
    "cmunobi.ttf", "cmunobx.ttf", "cmunorm.ttf", "cmunoti.ttf",
  ]

  private static let Libertinus: Array<String> = [
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

  private static let Noto: Array<String> = [
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

  private static let newComputerModern: Array<String> = [
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

  private static let STIX: Array<String> = [
    "STIXTwoMath-Regular.otf",
    "STIXTwoText-Bold.otf",
    "STIXTwoText-BoldItalic.otf",
    "STIXTwoText-Italic.otf",
    "STIXTwoText-Regular.otf",
  ]
}
