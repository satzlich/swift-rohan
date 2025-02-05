// Copyright 2024-2025 Lie Yan

public enum RohanIndex: Equatable, Hashable, CustomStringConvertible {
    case stableOffset(StableOffset)
    case arrayIndex(Int)
    case mathIndex(MathIndex)
    case gridIndex(GridIndex)

    public static func stableOffset(_ offset: Int, _ padding: Bool) -> RohanIndex {
        .stableOffset(StableOffset(offset, padding))
    }

    public static func gridIndex(_ row: Int, _ column: Int) -> RohanIndex {
        .gridIndex(GridIndex(row, column))
    }

    func stableOffset() -> StableOffset? {
        switch self {
        case let .stableOffset(offset): return offset
        default: return nil
        }
    }

    func arrayIndex() -> Int? {
        switch self {
        case let .arrayIndex(index): return index
        default: return nil
        }
    }

    func mathIndex() -> MathIndex? {
        switch self {
        case let .mathIndex(index): return index
        default: return nil
        }
    }

    func gridIndex() -> GridIndex? {
        switch self {
        case let .gridIndex(index): return index
        default: return nil
        }
    }

    public var description: String {
        switch self {
        case let .stableOffset(offset): return "\(offset)"
        case let .arrayIndex(index): return "\(index)↓"
        case let .mathIndex(index): return "\(index)"
        case let .gridIndex(index): return "\(index)"
        }
    }

    public struct StableOffset: Hashable, Comparable, CustomStringConvertible {
        /** offset from the first child to the target child */
        let offset: Int
        /** true if a padding unit is required for locating the child index */
        private let padding: Bool

        internal init(_ offset: Int, _ padding: Bool) {
            self.offset = offset
            self.padding = padding
        }

        var locatingValue: Int { offset + padding.intValue }

        public var description: String {
            "\(offset)" + (padding ? "→" : "")
        }

        public static func < (lhs: StableOffset, rhs: StableOffset) -> Bool {
            lhs.locatingValue < rhs.locatingValue
        }
    }

    public enum MathIndex: Int, Comparable, CustomStringConvertible {
        case nucleus = 0
        case subScript = 1
        case superScript = 2
        // fraction
        case numerator = 3
        case denominator = 4
        // radical
        case index = 5
        case radicand = 6

        public static func < (lhs: MathIndex, rhs: MathIndex) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        public var description: String {
            switch self {
            case .nucleus: return "nucleus"
            case .subScript: return "subscript"
            case .superScript: return "superscript"
            case .numerator: return "numerator"
            case .denominator: return "denominator"
            case .index: return "index"
            case .radicand: return "radicand"
            }
        }
    }

    public struct GridIndex: Hashable, Comparable, CustomStringConvertible {
        public let row: Int
        public let column: Int

        internal init(_ row: Int, _ column: Int) {
            precondition(GridIndex.validate(row: row))
            precondition(GridIndex.validate(column: column))
            self.row = row
            self.column = column
        }

        public var description: String {
            "(\(row), \(column))"
        }

        public static func < (lhs: GridIndex, rhs: GridIndex) -> Bool {
            (lhs.row, lhs.column) < (rhs.row, rhs.column)
        }

        /*
          We follow the practice of Microsoft Word.
          Column count must be between 1 and 63.
          Row count must be between 1 and 32767.
         */

        internal static func validate(row: Int) -> Bool {
            0 ..< 32767 ~= row
        }

        internal static func validate(column: Int) -> Bool {
            0 ..< 63 ~= column
        }
    }
}

public typealias StableOffset = RohanIndex.StableOffset
public typealias MathIndex = RohanIndex.MathIndex
