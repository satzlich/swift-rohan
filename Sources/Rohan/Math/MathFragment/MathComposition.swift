// Copyright 2024-2025 Lie Yan

import CoreGraphics

/**  Composite of math fragments */
struct MathComposition {
    typealias Item = (fragment: MathFragment, position: CGPoint)
    private let items: [Item]

    // MARK: - Metrics

    let width: Double
    var height: Double { ascent + descent }
    let ascent: Double
    let descent: Double
    let italicsCorrection: Double
    let accentAttachment: Double

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext) {
        for (fragment, position) in items {
            let point = CGPoint(x: point.x + position.x,
                                y: point.y + position.y)
            fragment.draw(at: point, in: context)
        }
    }

    init(width: Double,
         ascent: Double,
         descent: Double,
         italicsCorrection: Double,
         accentAttachment: Double,
         items: [Item])
    {
        precondition(items.isEmpty == false)
        self.width = width
        self.ascent = ascent
        self.descent = descent
        self.italicsCorrection = italicsCorrection
        self.accentAttachment = accentAttachment
        self.items = items
    }

    init() {
        self.width = 0
        self.ascent = 0
        self.descent = 0
        self.italicsCorrection = 0
        self.accentAttachment = 0
        self.items = []
    }

    /** Create natural horizontal composition */
    static func createHorizontal(_ fragments: [MathFragment]) -> MathComposition {
        var position = CGPoint.zero
        var items: [Item] = []
        items.reserveCapacity(fragments.count)
        for fragment in fragments {
            items.append((fragment, position))
            position.x += fragment.width
        }
        let width = position.x

        return MathComposition(width: width,
                               ascent: fragments.lazy.map(\.ascent).max() ?? 0,
                               descent: fragments.lazy.map(\.descent).max() ?? 0,
                               italicsCorrection: 0,
                               accentAttachment: width / 2,
                               items: items)
    }

    /** Create natural vertical composition */
    static func createVertical(_ fragments: [MathFragment],
                               height: Double,
                               baseline: Double) -> MathComposition
    {
        var position = CGPoint(x: 0, y: -baseline)
        var items: [Item] = []
        items.reserveCapacity(fragments.count)
        for fragment in fragments {
            position.y += fragment.ascent
            items.append((fragment, position))
            position.y += fragment.descent
        }

        let width = fragments.lazy.map(\.width).max() ?? 0
        return MathComposition(width: width,
                               ascent: baseline,
                               descent: height - baseline,
                               italicsCorrection: 0,
                               accentAttachment: width / 2,
                               items: items)
    }
}

struct CompositeGlyph {
    typealias Item = (fragment: GlyphFragment, position: CGPoint)
    private let items: [Item]

    // MARK: - Metrics

    let width: Double
    var height: Double { ascent + descent }
    let ascent: Double
    let descent: Double
    let italicsCorrection: Double
    let accentAttachment: Double

    // MARK: - Draw

    func draw(at point: CGPoint, in context: CGContext) {
        for (fragment, position) in items {
            let point = CGPoint(x: point.x + position.x,
                                y: point.y + position.y)
            fragment.draw(at: point, in: context)
        }
    }

    init(width: Double,
         ascent: Double,
         descent: Double,
         italicsCorrection: Double,
         accentAttachment: Double,
         items: [Item])
    {
        precondition(items.isEmpty == false)
        self.width = width
        self.ascent = ascent
        self.descent = descent
        self.italicsCorrection = italicsCorrection
        self.accentAttachment = accentAttachment
        self.items = items
    }
}
