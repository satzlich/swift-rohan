// Copyright 2024-2025 Lie Yan

struct LayoutLocation {
    private let _entries: [LocationEntry]

    init(_ entries: [LocationEntry]) {
        self._entries = entries
    }

    var isEmpty: Bool { @inline(__always) get { _entries.isEmpty } }
    var count: Int { @inline(__always) get { _entries.count } }
    subscript(index: Int) -> LocationEntry { @inline(__always) get { _entries[index] } }

    struct LocationEntry {
        let context: LayoutContext
        let location: Int

        init(_ context: LayoutContext, _ location: Int) {
            self.context = context
            self.location = location
        }
    }
}

struct LayoutRange {
    let parent: LayoutLocation
    let range: RangeEntry

    struct RangeEntry {
        let context: LayoutContext
        let location: Int
        let endLocation: Int

        init(_ context: LayoutContext, _ location: Int, _ endLocation: Int) {
            self.context = context
            self.location = location
            self.endLocation = endLocation
        }
    }
}
