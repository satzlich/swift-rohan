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
    ConcreteMath + CMUConcrete + LatinModern + LatinModernMath + Libertinus
    + NotoSans + NotoSansMath + NotoSerif + STIX

  private static let ConcreteMath: Array<String> = [
    "Concrete-Math.otf",
    "Concrete-Math-Bold.otf",
  ]

  private static let CMUConcrete: Array<String> = [
    "cmunobi.ttf", "cmunobx.ttf", "cmunorm.ttf", "cmunoti.ttf",
  ]

  private static let LatinModern: Array<String> = [
    "lmmono10-italic.otf",
    "lmmono10-regular.otf",
    "lmmono12-regular.otf",
    "lmmono8-regular.otf",
    "lmmono9-regular.otf",
    "lmmonocaps10-oblique.otf",
    "lmmonocaps10-regular.otf",
    "lmmonolt10-bold.otf",
    "lmmonolt10-boldoblique.otf",
    "lmmonolt10-oblique.otf",
    "lmmonolt10-regular.otf",
    "lmmonoltcond10-oblique.otf",
    "lmmonoltcond10-regular.otf",
    "lmmonoprop10-oblique.otf",
    "lmmonoprop10-regular.otf",
    "lmmonoproplt10-bold.otf",
    "lmmonoproplt10-boldoblique.otf",
    "lmmonoproplt10-oblique.otf",
    "lmmonoproplt10-regular.otf",
    "lmmonoslant10-regular.otf",
    "lmroman10-bold.otf",
    "lmroman10-bolditalic.otf",
    "lmroman10-italic.otf",
    "lmroman10-regular.otf",
    "lmroman12-bold.otf",
    "lmroman12-italic.otf",
    "lmroman12-regular.otf",
    "lmroman17-regular.otf",
    "lmroman5-bold.otf",
    "lmroman5-regular.otf",
    "lmroman6-bold.otf",
    "lmroman6-regular.otf",
    "lmroman7-bold.otf",
    "lmroman7-italic.otf",
    "lmroman7-regular.otf",
    "lmroman8-bold.otf",
    "lmroman8-italic.otf",
    "lmroman8-regular.otf",
    "lmroman9-bold.otf",
    "lmroman9-italic.otf",
    "lmroman9-regular.otf",
    "lmromancaps10-oblique.otf",
    "lmromancaps10-regular.otf",
    "lmromandemi10-oblique.otf",
    "lmromandemi10-regular.otf",
    "lmromandunh10-oblique.otf",
    "lmromandunh10-regular.otf",
    "lmromanslant10-bold.otf",
    "lmromanslant10-regular.otf",
    "lmromanslant12-regular.otf",
    "lmromanslant17-regular.otf",
    "lmromanslant8-regular.otf",
    "lmromanslant9-regular.otf",
    "lmromanunsl10-regular.otf",
    "lmsans10-bold.otf",
    "lmsans10-boldoblique.otf",
    "lmsans10-oblique.otf",
    "lmsans10-regular.otf",
    "lmsans12-oblique.otf",
    "lmsans12-regular.otf",
    "lmsans17-oblique.otf",
    "lmsans17-regular.otf",
    "lmsans8-oblique.otf",
    "lmsans8-regular.otf",
    "lmsans9-oblique.otf",
    "lmsans9-regular.otf",
    "lmsansdemicond10-oblique.otf",
    "lmsansdemicond10-regular.otf",
    "lmsansquot8-bold.otf",
    "lmsansquot8-boldoblique.otf",
    "lmsansquot8-oblique.otf",
    "lmsansquot8-regular.otf",
  ]

  private static let LatinModernMath: Array<String> = [
    "latinmodern-math.otf"
  ]

  private static let Libertinus: Array<String> = [
    "LibertinusKeyboard-Regular.otf",
    "LibertinusMath-Regular.otf",
    "LibertinusMono-Regular.otf",
    "LibertinusSans-Bold.otf",
    "LibertinusSans-Italic.otf",
    "LibertinusSans-Regular.otf",
    "LibertinusSerif-Bold.otf",
    "LibertinusSerif-BoldItalic.otf",
    "LibertinusSerif-Italic.otf",
    "LibertinusSerif-Regular.otf",
    "LibertinusSerif-Semibold.otf",
    "LibertinusSerif-SemiboldItalic.otf",
    "LibertinusSerifDisplay-Regular.otf",
    "LibertinusSerifInitials-Regular.otf",
  ]

  private static let NotoSans: Array<String> = [
    "NotoSans-Italic-VariableFont_wdth,wght.ttf",
    "NotoSans-VariableFont_wdth,wght.ttf",
  ]

  private static let NotoSansMath: Array<String> = [
    "NotoSansMath-Regular.ttf"
  ]

  private static let NotoSerif: Array<String> = [
    "NotoSerif_Condensed-Black.ttf",
    "NotoSerif_Condensed-BlackItalic.ttf",
    "NotoSerif_Condensed-Bold.ttf",
    "NotoSerif_Condensed-BoldItalic.ttf",
    "NotoSerif_Condensed-ExtraBold.ttf",
    "NotoSerif_Condensed-ExtraBoldItalic.ttf",
    "NotoSerif_Condensed-ExtraLight.ttf",
    "NotoSerif_Condensed-ExtraLightItalic.ttf",
    "NotoSerif_Condensed-Italic.ttf",
    "NotoSerif_Condensed-Light.ttf",
    "NotoSerif_Condensed-LightItalic.ttf",
    "NotoSerif_Condensed-Medium.ttf",
    "NotoSerif_Condensed-MediumItalic.ttf",
    "NotoSerif_Condensed-Regular.ttf",
    "NotoSerif_Condensed-SemiBold.ttf",
    "NotoSerif_Condensed-SemiBoldItalic.ttf",
    "NotoSerif_Condensed-Thin.ttf",
    "NotoSerif_Condensed-ThinItalic.ttf",
    "NotoSerif_ExtraCondensed-Black.ttf",
    "NotoSerif_ExtraCondensed-BlackItalic.ttf",
    "NotoSerif_ExtraCondensed-Bold.ttf",
    "NotoSerif_ExtraCondensed-BoldItalic.ttf",
    "NotoSerif_ExtraCondensed-ExtraBold.ttf",
    "NotoSerif_ExtraCondensed-ExtraBoldItalic.ttf",
    "NotoSerif_ExtraCondensed-ExtraLight.ttf",
    "NotoSerif_ExtraCondensed-ExtraLightItalic.ttf",
    "NotoSerif_ExtraCondensed-Italic.ttf",
    "NotoSerif_ExtraCondensed-Light.ttf",
    "NotoSerif_ExtraCondensed-LightItalic.ttf",
    "NotoSerif_ExtraCondensed-Medium.ttf",
    "NotoSerif_ExtraCondensed-MediumItalic.ttf",
    "NotoSerif_ExtraCondensed-Regular.ttf",
    "NotoSerif_ExtraCondensed-SemiBold.ttf",
    "NotoSerif_ExtraCondensed-SemiBoldItalic.ttf",
    "NotoSerif_ExtraCondensed-Thin.ttf",
    "NotoSerif_ExtraCondensed-ThinItalic.ttf",
    "NotoSerif_SemiCondensed-Black.ttf",
    "NotoSerif_SemiCondensed-BlackItalic.ttf",
    "NotoSerif_SemiCondensed-Bold.ttf",
    "NotoSerif_SemiCondensed-BoldItalic.ttf",
    "NotoSerif_SemiCondensed-ExtraBold.ttf",
    "NotoSerif_SemiCondensed-ExtraBoldItalic.ttf",
    "NotoSerif_SemiCondensed-ExtraLight.ttf",
    "NotoSerif_SemiCondensed-ExtraLightItalic.ttf",
    "NotoSerif_SemiCondensed-Italic.ttf",
    "NotoSerif_SemiCondensed-Light.ttf",
    "NotoSerif_SemiCondensed-LightItalic.ttf",
    "NotoSerif_SemiCondensed-Medium.ttf",
    "NotoSerif_SemiCondensed-MediumItalic.ttf",
    "NotoSerif_SemiCondensed-Regular.ttf",
    "NotoSerif_SemiCondensed-SemiBold.ttf",
    "NotoSerif_SemiCondensed-SemiBoldItalic.ttf",
    "NotoSerif_SemiCondensed-Thin.ttf",
    "NotoSerif_SemiCondensed-ThinItalic.ttf",
    "NotoSerif-Black.ttf",
    "NotoSerif-BlackItalic.ttf",
    "NotoSerif-Bold.ttf",
    "NotoSerif-BoldItalic.ttf",
    "NotoSerif-ExtraBold.ttf",
    "NotoSerif-ExtraBoldItalic.ttf",
    "NotoSerif-ExtraLight.ttf",
    "NotoSerif-ExtraLightItalic.ttf",
    "NotoSerif-Italic.ttf",
    "NotoSerif-Light.ttf",
    "NotoSerif-LightItalic.ttf",
    "NotoSerif-Medium.ttf",
    "NotoSerif-MediumItalic.ttf",
    "NotoSerif-Regular.ttf",
    "NotoSerif-SemiBold.ttf",
    "NotoSerif-SemiBoldItalic.ttf",
    "NotoSerif-Thin.ttf",
    "NotoSerif-ThinItalic.ttf",

  ]

  private static let STIX: Array<String> = [
    "STIXTwoMath-Regular.otf",
    "STIXTwoText-Bold.otf",
    "STIXTwoText-BoldItalic.otf",
    "STIXTwoText-Italic.otf",
    "STIXTwoText-Medium.otf",
    "STIXTwoText-MediumItalic.otf",
    "STIXTwoText-Regular.otf",
    "STIXTwoText-SemiBold.otf",
    "STIXTwoText-SemiBoldItalic.otf",
  ]
}
