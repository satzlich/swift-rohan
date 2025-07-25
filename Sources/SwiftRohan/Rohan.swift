import LatexParser
import OSLog
import _RopeModule

internal enum Rohan {
  static let domain = "net.satzlich.rohan"
  static let logger = Logger(subsystem: domain, category: "Rohan")

  /// tolerance for layout calculations
  static let tolerance: Double = 1e-6

  /// True if text in math mode should be auto-italicised.
  static let autoItalic: Bool = true

  /// leading padding for text layout fragments. This is a global constant and
  /// should not be changed.
  static let fragmentPadding: Double = 5
}

extension Rohan {
  nonisolated(unsafe) static let latexRegistry: LatexRegistry = _latexRegistry()

  private static func _latexRegistry() -> LatexRegistry {
    var registry = LatexRegistry()

    // register all commands
    // NOTE: some commands such as \sqrt are skipped
    for command in CommandDeclaration.allCommands {
      let controlWord = ControlWordToken(name: NameToken(command.command)!)
      let record = ControlSeqRecord(controlWord, command.tag, command.source)
      let old = registry.registerCommand(record)
      assert(old == nil, "Command '\(command.command)' already registered.")
    }

    // register all substitutions
    do {
      let textSubs: Dictionary<Character, Array<StreamletSyntax>> = [
        "“": [.text(TextSyntax(rawValue: "``", mode: .rawMode))],
        "”": [.text(TextSyntax(rawValue: "''", mode: .rawMode))],
      ]
      for (character, syntax) in textSubs {
        let old = registry.registerSubstitution(
          SubstitutionRecord(character, syntax, mode: .textMode))
        assert(old == nil, "Substitution '\(character)' already registered.")
      }
    }
    do {
      let mathSubs: Dictionary<Character, Array<StreamletSyntax>> = [
        " ": [.controlSymbol(ControlSymbolSyntax(command: ControlSymbolToken.space))],
        "\u{2032}": [.controlWord(ControlWordSyntax(command: ControlWordToken.prime))],
        "\u{2033}": [.controlWord(ControlWordSyntax(command: ControlWordToken.dprime))],
        "\u{2034}": [.controlWord(ControlWordSyntax(command: ControlWordToken.trprime))],
        "\u{2057}": [.controlWord(ControlWordSyntax(command: ControlWordToken.qprime))],
      ]

      for (character, syntax) in mathSubs {
        let old = registry.registerSubstitution(
          SubstitutionRecord(character, syntax, mode: .mathMode))
        assert(old == nil, "Substitution '\(character)' already registered.")
      }
    }

    // add preamble
    do {
      let preamble =
        #"""
        % !TEX program = xelatex
        \documentclass[10pt]{article}
        \usepackage[usenames]{color}
        \usepackage{amssymb}
        \usepackage{amsmath}
        \usepackage{amsthm}
        \usepackage[utf8]{inputenc}
        \usepackage{mathtools}
        \usepackage{unicode-math}

        \newtheorem{theorem}{Theorem}
        \newtheorem{lemma}{Lemma}
        \newtheorem{corollary}{Corollary}

        %\setlength\parindent{0pt}
        \setlength{\parskip}{0.5em}

        """#
      registry.preamble = preamble
    }

    return registry
  }
}

/// Returns the duplicates in the given sequence of strings.
internal func findDuplicates<T: Hashable & Equatable>(
  in sequences: some Sequence<T>
) -> Array<T> {
  var seen = Set<T>()
  var duplicates = Set<T>()

  for element in sequences {
    if seen.contains(element) {
      duplicates.insert(element)
    }
    else {
      seen.insert(element)
    }
  }

  return Array(duplicates)
}

@inlinable @inline(__always)
func runOnMainThread<T: Sendable>(_ block: @MainActor () throws -> T) rethrows -> T {
  if Thread.isMainThread {
    try MainActor.assumeIsolated { try block() }
  }
  else {
    try DispatchQueue.main.sync { try block() }
  }
}
