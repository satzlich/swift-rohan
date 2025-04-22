// Copyright 2024-2025 Lie Yan

import Algorithms
import SatzAlgorithms

struct ReplacementEngine {
  private let rules: [ReplacementRule]

  /// maximum character count of all prefixes
  private let maxPrefixSize: Int

  /// set of characters in the replacement rules
  private let charSet: Set<Character>

  /// char map for single character replacement
  private let charMap: [Character: CommandBody]
  /// string map for prefix replacement where key is reversed "preifx + character"
  private let stringMap: TSTree<CommandBody>

  init(_ rules: [ReplacementRule]) {
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
      let pairs: [(string: String, command: CommandBody)] = s1.map { rule in
        (String(rule.character) + rule.prefix.reversed(), rule.command)
      }

      assert(StringUtils.isPrefixFree(pairs.map(\.string)))

      let stringMap = TSTree<CommandBody>()
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

  /// Returns the replacement command for the given character and prefix.
  func replacement(
    for character: Character, prefix: String
  ) -> (CommandBody, prefix: Int)? {
    if !prefix.isEmpty {
      let string = String(character) + prefix.reversed()
      let key = stringMap.findPrefix(of: string)
      if !key.isEmpty {
        return stringMap.get(String(key)).map { ($0, key.count - 1) }
      }
      // FALL THROUGH
    }

    if let command = charMap[character] {
      return (command, 0)
    }
    return nil
  }
}
