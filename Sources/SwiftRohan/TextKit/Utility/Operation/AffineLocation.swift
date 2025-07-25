import Foundation

/// Location resolved from coordinates
struct AffineLocation {
  let value: TextLocation
  let affinity: SelectionAffinity

  init(_ value: TextLocation, _ affinity: SelectionAffinity) {
    self.value = value
    self.affinity = affinity
  }
}
