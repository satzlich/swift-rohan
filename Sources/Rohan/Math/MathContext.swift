// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import TTFParser

/** Font-related context for math layout */
public final class MathContext {
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

extension MathUtils {
    /** Resolve math context for node */
    static func resolveMathContext(for node: Node,
                                   _ styleSheet: StyleSheet) -> MathContext
    {
        let textSize = node.resolveProperty(TextProperty.size, styleSheet)
        let mathFont = node.resolveProperty(MathProperty.font, styleSheet)

        let mathFont_ = Font.createWithName(mathFont.string()!,
                                            textSize.fontSize()!.floatValue,
                                            isFlipped: true)
        guard let mathContext = MathContext(mathFont_)
        else { fatalError("TODO: return fallback math context") }
        return mathContext
    }
}
