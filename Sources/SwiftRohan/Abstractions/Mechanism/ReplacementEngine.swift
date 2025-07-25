import Algorithms
import SatzAlgorithms

public struct ReplacementEngine {
  private let rules: Array<ReplacementRule>

  /// maximum character count of all prefixes
  private let maxPrefixSize: Int

  /// set of characters in the replacement rules
  private let charSet: Set<Character>

  /// char map for single character replacement
  private let charMap: Dictionary<Character, CommandBody>

  /// string map for prefix replacement where key is "preifx + character" **reversed**.
  private typealias StringMap = GenericTSTree<ExtendedChar, CommandBody>
  private let stringMap: StringMap

  public init(_ rules: Array<ReplacementRule>) {
    self.rules = rules
    self.maxPrefixSize = rules.map { $0.prefix.count }.max() ?? 0
    self.charSet = Set(rules.map(\.character))

    let (s0, s1) = rules.partitioned { $0.prefix.isEmpty == false }

    self.charMap = s0.reduce(into: [:]) { map, rule in
      let key = rule.character
      let value = rule.command
      let old = map.updateValue(value, forKey: key)
      assert(old == nil, "Duplicate character replacement: \(key)")
    }

    do {
      let pairs: [(string: ExtendedString, command: CommandBody)] = s1.map { rule in
        var pattern = rule.prefix.toExtendedString() + [ExtendedChar.char(rule.character)]
        pattern.reverse()
        return (pattern, rule.command)
      }

      #if DEBUG
      do {
        let duplicates = findDuplicates(in: pairs.map(\.string))
        assert(duplicates.isEmpty, "Duplicates found: \(duplicates)")
      }
      #endif

      let stringMap = StringMap()
      for (string, command) in pairs.shuffled() {
        stringMap.insert(string, command)
      }
      self.stringMap = stringMap
    }
  }

  /// Returns the maximum prefix size (number of characters) for the given character.
  /// Or nil if the character is not in the replacement rules.
  func prefixSize(for character: Character) -> Int? {
    guard charSet.contains(character) else { return nil }
    return maxPrefixSize
  }

  /// Returns the replacement command for the given character and the matched prefix
  /// in **reversed** order. Or nil if no replacement rule is matched.
  func replacement(
    for character: Character, prefix: ExtendedString
  ) -> (CommandBody, prefix: ExtendedSubstring)? {
    if !prefix.isEmpty {
      var string = prefix + [ExtendedChar.char(character)]
      // reverse in-place
      string.reverse()

      let key = Array(stringMap.findPrefix(of: string))
      if !key.isEmpty {
        return stringMap.get(key).map { ($0, key.dropFirst()) }
      }
      // FALL THROUGH
    }

    if let command = charMap[character] {
      return (command, ExtendedSubstring())
    }
    return nil
  }

  func replacement(
    for character: Character, prefix: String
  ) -> (CommandBody, prefix: ExtendedSubstring)? {
    replacement(for: character, prefix: ExtendedString(prefix))
  }
}
