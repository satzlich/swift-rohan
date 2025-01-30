// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

/** Font-related data for math layout */
private final class _MathFont {
    let font: Font
    let table: MathTable
    let constants: MathConstantsTable

    private(set) lazy var scriptFont: Font = {
        let scaleDown = CGFloat(constants.scriptPercentScaleDown) / 100
        return font.createCopy(font.size * scaleDown)
    }()

    private(set) lazy var scriptScriptFont: Font = {
        let scaleDown = CGFloat(constants.scriptScriptPercentScaleDown) / 100
        return font.createCopy(font.size * scaleDown)
    }()

    init?(_ font: Font) {
        guard let table = font.copyMathTable(),
              let constants = table.constants
        else { return nil }
        self.font = font
        self.table = table
        self.constants = constants
    }

    func getFont(for style: MathStyle) -> Font {
        switch style {
        case .display, .text:
            return font
        case .script:
            return scriptFont
        case .scriptScript:
            return scriptScriptFont
        }
    }
}

struct MathContext {
    private let mathFont: _MathFont

    var table: MathTable { mathFont.table }
    var constants: MathConstantsTable { mathFont.constants }
    let mathStyle: MathStyle

    init?(_ font: Font, _ mathStyle: MathStyle) {
        guard let mathFont = _MathFont(font) else { return nil }
        self.mathFont = mathFont
        self.mathStyle = mathStyle
    }

    private init(_ mathFont: _MathFont, _ mathStyle: MathStyle) {
        self.mathFont = mathFont
        self.mathStyle = mathStyle
    }

    func with(mathStyle: MathStyle) -> MathContext {
        MathContext(mathFont, mathStyle)
    }

    func getFont(for style: MathStyle) -> Font {
        mathFont.getFont(for: style)
    }

    /** Returns the font for the current math style */
    func getFont() -> Font {
        mathFont.getFont(for: mathStyle)
    }
}

extension MathUtils {
    /** Resolve math context for node */
    static func resolveMathContext(for node: Node,
                                   _ styleSheet: StyleSheet) -> MathContext
    {
        let textSize = node.resolveProperty(TextProperty.size, styleSheet)
        let fontName = node.resolveProperty(MathProperty.font, styleSheet)

        let mathFont = Font.createWithName(fontName.string()!,
                                           textSize.fontSize()!.floatValue,
                                           isFlipped: true)

        let mathStyle = node.resolveProperty(MathProperty.style, styleSheet).mathStyle()!

        guard let mathContext = MathContext(mathFont, mathStyle)
        else { fatalError("TODO: return fallback math context") }
        return mathContext
    }
}
