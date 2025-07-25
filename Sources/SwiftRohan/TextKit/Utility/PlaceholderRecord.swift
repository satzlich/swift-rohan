internal struct PlaceholderRecord {
  let char: Character
  let isVisible: Bool

  init(_ char: Character, _ isVisible: Bool) {
    self.char = char
    self.isVisible = isVisible
  }
}
