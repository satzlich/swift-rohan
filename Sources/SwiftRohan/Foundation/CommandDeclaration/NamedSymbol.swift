import Foundation
import LatexParser

struct NamedSymbol: Codable, CommandDeclarationProtocol {
  let command: String
  let tag: CommandTag
  var source: CommandSource { .preBuilt }

  let string: String
  let contentMode: ContentMode

  init(
    _ command: String, _ string: String,
    contentMode: ContentMode = .math,
    tag: CommandTag = .namedSymbol
  ) {
    self.command = command
    self.string = string
    self.contentMode = contentMode
    self.tag = tag
  }

  // MARK: - Preview

  func preview() -> String {
    if let preview = Self._previewCache[command] {
      return preview
    }
    else {
      assertionFailure("No preview for \(command)")
      return _preview()
    }
  }

  private func _preview() -> String {
    switch contentMode {
    case .math:
      if string.count == 1,
        let char = string.first
      {
        if char.isWhitespace {
          return "␣"
        }
        else {
          let styled = MathUtils.styledChar(
            for: char, variant: .serif, bold: false, italic: nil, autoItalic: true)
          return String(styled)
        }
      }
      else if string.allSatisfy({ $0.isWhitespace }) {
        return String(repeating: "␣", count: string.count)
      }
      else {
        return string
      }
    case .text, .universal:
      return string.count > 3 ? string.prefix(2) + "…" : string
    }

  }

  private static let _previewCache: Dictionary<String, String> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0._preview()) })
}

extension NamedSymbol: Equatable, Hashable {
  static func == (lhs: NamedSymbol, rhs: NamedSymbol) -> Bool {
    lhs.command == rhs.command && lhs.contentMode == rhs.contentMode
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(command)
    hasher.combine(contentMode)
  }
}

extension NamedSymbol: Comparable {
  static func < (lhs: NamedSymbol, rhs: NamedSymbol) -> Bool {
    if lhs.contentMode != rhs.contentMode {
      return lhs.contentMode < rhs.contentMode
    }
    else {
      return lhs.command < rhs.command
    }
  }
}

extension NamedSymbol {
  static let allCommands: Array<NamedSymbol> = mathSymbols + universalSymbols

  private static let _dictionary: Dictionary<String, NamedSymbol> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> NamedSymbol? { _dictionary[command] }

  static let universalSymbols: Array<NamedSymbol> = LatexCommands.universalSymbols

  static let mathSymbols: Array<NamedSymbol> =
    LatexCommands.mathSymbols + AMSCommands.mathSymbols + OtherCommands.mathSymbols
}

/// Symbols defined in LaTeX
private enum LatexCommands {
  static let universalSymbols: Array<NamedSymbol> = [
    .init("dag", "\u{2020}", contentMode: .universal),  // †
    .init("ddag", "\u{2021}", contentMode: .universal),  // ‡
    .init("P", "\u{00B6}", contentMode: .universal),  // ¶
    .init("S", "\u{00A7}", contentMode: .universal),  // §
  ]

  static let mathSymbols: Array<NamedSymbol> =
    binaryOperators + largeOperators + binaryRelations + subsetRelations
    + inequalities + arrows + harpoons + greekLetters + letterLikeSymbols
    + variableSizedDelimiters + largeDelimiters + dots + miscellaneous
    + otherVerified

  // total: 36 symbols
  private static let binaryOperators: Array<NamedSymbol> = [
    .init("amalg", "\u{2A3F}"),  // ⨿
    .init("ast", "\u{2217}"),  // ∗
    .init("bigcirc", "\u{25EF}"),  // ◯
    .init("bigtriangledown", "\u{25BD}"),  // ▽
    .init("bigtriangleup", "\u{25B3}"),  // △
    .init("bullet", "\u{2219}"),  // ∙
    .init("cap", "\u{2229}"),  // ∩
    .init("cdot", "\u{22C5}"),  // ⋅
    .init("circ", "\u{2218}"),  // ∘
    .init("cup", "\u{222A}"),  // ∪
    // .init("dagger", "\u{2020}"),  // † (defined as MathExpression)
    // .init("ddagger", "\u{2021}"),  // ‡ (defined as MathExpression)
    .init("diamond", "\u{22C4}"),  // ⋄
    .init("div", "\u{00F7}"),  // ÷
    .init("lhd", "\u{22B2}"),  // ⊲ (from latexsym package)
    .init("mp", "\u{2213}"),  // ∓
    .init("odot", "\u{2299}"),  // ⊙
    .init("ominus", "\u{2296}"),  // ⊖
    .init("oplus", "\u{2295}"),  // ⊕
    .init("oslash", "\u{2298}"),  // ⊘
    .init("otimes", "\u{2297}"),  // ⊗
    .init("pm", "\u{00B1}"),  // ±
    .init("rhd", "\u{22B3}"),  // ⊳ (from latexsym package)
    .init("setminus", "\u{2216}"),  // ∖
    .init("sqcap", "\u{2293}"),  // ⊓
    .init("sqcup", "\u{2294}"),  // ⊔
    .init("star", "\u{22C6}"),  // ⋆
    .init("times", "\u{00D7}"),  // ×
    .init("triangleleft", "\u{25C1}"),  // ◁
    .init("triangleright", "\u{25B7}"),  // ▷
    .init("unlhd", "\u{22B4}"),  // ⊴ (from latexsym package)
    .init("unrhd", "\u{22B5}"),  // ⊵ (from latexsym package)
    .init("uplus", "\u{228E}"),  // ⊎
    .init("vee", "\u{2228}"),  // ∨
    .init("wedge", "\u{2227}"),  // ∧
    .init("wr", "\u{2240}"),  // ≀
  ]

  // total: 14 symbols
  private static let largeOperators: Array<NamedSymbol> = [
    .init("bigcap", "\u{22C2}", tag: [.mathOperator, .namedSymbol]),  // ⋂
    .init("bigcup", "\u{22C3}", tag: [.mathOperator, .namedSymbol]),  // ⋃
    .init("bigodot", "\u{2A00}", tag: [.mathOperator, .namedSymbol]),  // ⨀
    .init("bigoplus", "\u{2A01}", tag: [.mathOperator, .namedSymbol]),  // ⨁
    .init("bigotimes", "\u{2A02}", tag: [.mathOperator, .namedSymbol]),  // ⨂
    .init("bigsqcup", "\u{2A06}", tag: [.mathOperator, .namedSymbol]),  // ⨆
    .init("biguplus", "\u{2A04}", tag: [.mathOperator, .namedSymbol]),  // ⨄
    .init("bigvee", "\u{22C1}", tag: [.mathOperator, .namedSymbol]),  // ⋁
    .init("bigwedge", "\u{22C0}", tag: [.mathOperator, .namedSymbol]),  // ⋀
    .init("coprod", "\u{2210}", tag: [.mathOperator, .namedSymbol]),  // ∐
    .init("prod", "\u{220F}", tag: [.mathOperator, .namedSymbol]),  // ∏
    .init("sum", "\u{2211}", tag: [.mathOperator, .namedSymbol]),  // ∑
    .init("int", "\u{222B}", tag: .mathOperator),  // ∫
    .init("oint", "\u{222E}", tag: .mathOperator),  // ∮
  ]

  // total: 22 symbols
  private static let binaryRelations: Array<NamedSymbol> = [
    .init("approx", "\u{2248}"),  // ≈
    .init("asymp", "\u{224D}"),  // ≍
    .init("bowtie", "\u{22C8}"),  // ⋈
    .init("cong", "\u{2245}"),  // ≅
    .init("dashv", "\u{22A3}"),  // ⊣
    .init("doteq", "\u{2250}"),  // ≐
    .init("equiv", "\u{2261}"),  // ≡
    .init("frown", "\u{2322}"),  // ⌢
    .init("Join", "\u{2A1D}"),  // ⨝ (defined in latexsym package)
    .init("mid", "\u{2223}"),  // ∣
    .init("models", "\u{22A7}"),  // ⊧
    .init("parallel", "\u{2225}"),  // ∥
    .init("perp", "\u{22A5}"),  // ⊥
    .init("prec", "\u{227A}"),  // ≺
    .init("preceq", "\u{2AAF}"),  // ⪯
    .init("propto", "\u{221D}"),  // ∝
    .init("sim", "\u{223C}"),  // ∼
    .init("simeq", "\u{2243}"),  // ≃
    .init("smile", "\u{2323}"),  // ⌣
    .init("succ", "\u{227B}"),  // ≻
    .init("succeq", "\u{2AB0}"),  // ⪰
    .init("vdash", "\u{22A2}"),  // ⊢
  ]

  // total: 8 symbols
  private static let subsetRelations: Array<NamedSymbol> = [
    .init("sqsubset", "\u{228F}"),  // ⊏ (defined in latexsym package)
    .init("sqsubseteq", "\u{2291}"),  // ⊑
    .init("sqsupset", "\u{2290}"),  // ⊐ (defined in latexsym package)
    .init("sqsupseteq", "\u{2292}"),  // ⊒
    .init("subset", "\u{2282}"),  // ⊂
    .init("subseteq", "\u{2286}"),  // ⊆
    .init("supset", "\u{2283}"),  // ⊃
    .init("supseteq", "\u{2287}"),  // ⊇
  ]

  // total: 5 symbols
  private static let inequalities: Array<NamedSymbol> = [
    .init("geq", "\u{2265}"),  // ≥
    .init("gg", "\u{226B}"),  // ≫
    .init("leq", "\u{2264}"),  // ≤
    .init("ll", "\u{226A}"),  // ≪
    .init("neq", "\u{2260}"),  // ≠
  ]

  // total: 27 symbols
  private static let arrows: Array<NamedSymbol> = [
    .init("Downarrow", "\u{21D3}"),  // ⇓
    .init("downarrow", "\u{2193}"),  // ↓
    .init("hookleftarrow", "\u{21A9}"),  // ↩
    .init("hookrightarrow", "\u{21AA}"),  // ↪
    .init("leadsto", "\u{21DD}"),  // ⇝ (defined in latexsym package)
    .init("leftarrow", "\u{2190}"),  // ←
    .init("Leftarrow", "\u{21D0}"),  // ⇐
    .init("Leftrightarrow", "\u{21D4}"),  // ⇔
    .init("leftrightarrow", "\u{2194}"),  // ↔
    .init("longleftarrow", "\u{27F5}"),  // ⟵
    .init("Longleftarrow", "\u{27F8}"),  // ⟸
    .init("longleftrightarrow", "\u{27F7}"),  // ⟷
    .init("Longleftrightarrow", "\u{27FA}"),  // ⟺
    .init("longmapsto", "\u{27FC}"),  // ⟼
    .init("Longrightarrow", "\u{27F9}"),  // ⟹
    .init("longrightarrow", "\u{27F6}"),  // ⟶
    .init("mapsto", "\u{21A6}"),  // ↦
    .init("nearrow", "\u{2197}"),  // ↗
    .init("nwarrow", "\u{2196}"),  // ↖
    .init("Rightarrow", "\u{21D2}"),  // ⇒
    .init("rightarrow", "\u{2192}"),  // →
    .init("searrow", "\u{2198}"),  // ↘
    .init("swarrow", "\u{2199}"),  // ↙
    .init("uparrow", "\u{2191}"),  // ↑
    .init("Uparrow", "\u{21D1}"),  // ⇑
    .init("updownarrow", "\u{2195}"),  // ↕
    .init("Updownarrow", "\u{21D5}"),  // ⇕
  ]

  // total: 5 symbols
  private static let harpoons: Array<NamedSymbol> = [
    .init("leftharpoondown", "\u{21BD}"),  // ↽
    .init("leftharpoonup", "\u{21BC}"),  // ↼
    .init("rightharpoondown", "\u{21C1}"),  // ⇁
    .init("rightharpoonup", "\u{21C0}"),  // ⇀
    .init("rightleftharpoons", "\u{21CC}"),  // ⇌
  ]

  // total: 2 symbols
  private static let extensionCharacters: Array<NamedSymbol> = [
    // .init("relbar", "-"), // turned off
    // .init("Relbar", "="), // turned off
  ]

  // total: 41 symbols
  private static let greekLetters: Array<NamedSymbol> = [
    .init("alpha", "\u{03B1}"),  // α
    .init("beta", "\u{03B2}"),  // β
    .init("gamma", "\u{03B3}"),  // γ
    .init("delta", "\u{03B4}"),  // δ
    .init("epsilon", "\u{03F5}"),  // ϵ
    .init("varepsilon", "\u{03B5}"),  // ε
    .init("zeta", "\u{03B6}"),  // ζ
    .init("eta", "\u{03B7}"),  // η
    .init("theta", "\u{03B8}"),  // θ
    .init("vartheta", "\u{03D1}"),  // ϑ
    .init("iota", "\u{03B9}"),  // ι
    .init("kappa", "\u{03BA}"),  // κ
    .init("lambda", "\u{03BB}"),  // λ
    .init("mu", "\u{03BC}"),  // μ
    .init("nu", "\u{03BD}"),  // ν
    .init("xi", "\u{03BE}"),  // ξ
    // omicron is not defined
    .init("pi", "\u{03C0}"),  // π
    .init("varpi", "\u{03D6}"),  // ϖ
    .init("rho", "\u{03C1}"),  // ρ
    .init("varrho", "\u{03F1}"),  // ϱ
    .init("sigma", "\u{03C3}"),  // σ
    .init("varsigma", "\u{03C2}"),  // ς
    .init("tau", "\u{03C4}"),  // τ
    .init("upsilon", "\u{03C5}"),  // υ
    .init("phi", "\u{03D5}"),  // ϕ
    .init("varphi", "\u{03C6}"),  // φ
    .init("chi", "\u{03C7}"),  // χ
    .init("psi", "\u{03C8}"),  // ψ
    .init("omega", "\u{03C9}"),  // ω
    .init("Gamma", "\u{0393}"),  // Γ
    .init("Delta", "\u{0394}"),  // Δ
    .init("Theta", "\u{0398}"),  // Θ
    .init("Lambda", "\u{039B}"),  // Λ
    .init("Xi", "\u{039E}"),  // Ξ
    .init("Pi", "\u{03A0}"),  // Π
    .init("Sigma", "\u{03A3}"),  // Σ
    .init("Upsilon", "\u{03A5}"),  // Υ
    .init("Phi", "\u{03A6}"),  // Φ
    .init("Psi", "\u{03A8}"),  // Ψ
    .init("Omega", "\u{03A9}"),  // Ω
  ]

  // total: 14 symbols
  private static let letterLikeSymbols: Array<NamedSymbol> = [
    // .init("bot", "\u{22A5}"),  // ⊥ (defined as MathExpression for Normal class)
    .init("ell", "\u{2113}"),  // ℓ
    .init("exists", "\u{2203}"),  // ∃
    .init("forall", "\u{2200}"),  // ∀
    .init("hbar", "\u{210F}"),  // ℏ
    .init("Im", "\u{2111}"),  // ℑ
    .init("imath", "\u{0131}"),  // ı
    .init("in", "\u{2208}"),  // ∈
    .init("jmath", "\u{0237}"),  // ȷ
    .init("ni", "\u{220B}"),  // ∋
    .init("partial", "\u{2202}"),  // ∂
    .init("Re", "\u{211C}"),  // ℜ
    .init("top", "\u{22A4}"),  // ⊤
    .init("wp", "\u{2118}"),  // ℘
  ]

  // total: 22 symbols (left-to-right)
  private static let variableSizedDelimiters: Array<NamedSymbol> = [
    // .init("downarrow", "\u{2193}"),  // ↓ (duplicated in `arrows`)
    // .init("Downarrow", "\u{21D3}"),  // ⇓ (duplicated in `arrows`)
    // [
    // ]
    .init("langle", "\u{27E8}"),  // ⟨
    .init("rangle", "\u{27E9}"),  // ⟩
    // |
    // \|
    .init("lceil", "\u{2308}"),  // ⌈
    .init("rceil", "\u{2309}"),  // ⌉
    // .init("uparrow", "\u{2191}"),  // ↑ (duplicated in `arrows`)
    // .init("Uparrow", "\u{21D1}"),  // ⇑ (duplicated in `arrows`)
    .init("lfloor", "\u{230A}"),  // ⌊
    .init("rfloor", "\u{230B}"),  // ⌋
    // .init("updownarrow", "\u{2195}"),  // ↕ (duplicated in `arrows`)
    // .init("Updownarrow", "\u{21D5}"),  // ⇕ (duplicated in `arrows`)
    // (
    // )
    // {
    // }
    // /
    .init("backslash", "\u{005C}"),  // \
  ]

  // total: 7 symbols
  private static let largeDelimiters: Array<NamedSymbol> = [
    .init("lmoustache", "\u{23B0}"),  // ⎰
    .init("rmoustache", "\u{23B1}"),  // ⎱
    .init("lgroup", "\u{27EE}"),  // ⟮
    .init("rgroup", "\u{27EF}"),  // ⟯
    // Deprecated: \arrowvert, \Arrowvert, \bracevert
  ]

  // total: 7 symbols
  private static let dots: Array<NamedSymbol> = [
    .init("cdotp", "\u{00B7}"),  // ⋅ (alternative: U+22C5)
    .init("cdots", "\u{22EF}"),  // ⋯
    // \colon defined in MathExpression
    .init("ddots", "\u{22F1}"),  // ⋱
    .init("ldotp", "\u{002E}"),  // .
    .init("ldots", "\u{2026}"),  // …
    .init("vdots", "\u{22EE}"),  // ⋮
  ]

  // Table 334. total: 13 symbols
  private static let miscellaneous: Array<NamedSymbol> = [
    .init("aleph", "\u{2135}"),  // ℵ (Hebrew letter)
    .init("emptyset", "\u{2205}"),  // ∅
    .init("angle", "\u{2220}"),  // ∠
    // .init("backslash", "\u{005C}"),  // \ (duplicated in `variableSizedDelimiters`)
    .init("Box", "\u{25A1}"),  // ☐
    .init("Diamond", "\u{25CA}"),  // ◊
    .init("infty", "\u{221E}"),  // ∞
    .init("mho", "\u{2127}"),  // ℧
    .init("nabla", "\u{2207}"),  // ∇
    .init("neg", "\u{00AC}"),  // ¬
    .init("prime", "\u{2032}"),  // ′
    .init("surd", "\u{221A}"),  // √
    .init("triangle", "\u{25B3}"),  // △
  ]

  private static let otherVerified: Array<NamedSymbol> = [
    // NOTE: `\P` is defined in `universalSymbols`.
    // NOTE: `\S` is defined in `universalSymbols`.
    .init("copyright", "\u{00A9}"),  // ©
    .init("pounds", "\u{00A3}"),  // £
    // membership
    .init("notin", "\u{2209}"),  // ∉
    .init("owns", "\u{220B}"),  // ∋
    // logical
    .init("lnot", "\u{00AC}"),  // ¬
    .init("land", "\u{2227}"),  // ∧
    .init("lor", "\u{2228}"),  // ∨
    // suits
    .init("clubsuit", "\u{2663}"),  // ♣
    .init("diamondsuit", "\u{2662}"),  // ♢
    .init("spadesuit", "\u{2660}"),  // ♠
    .init("heartsuit", "\u{2661}"),  // ♡
    // music
    .init("flat", "\u{266D}"),  // ♭
    .init("natural", "\u{266E}"),  // ♮
    .init("sharp", "\u{266F}"),  // ♯
    // inequalities
    .init("ge", "\u{2265}"),  // ≥
    .init("le", "\u{2264}"),  // ≤
    .init("ne", "\u{2260}"),  // ≠
    // integeral
    .init("intop", "\u{222B}"),  // ∫
    // .init("smallint", "\u{222B}"),  // ∫ (Needs a smaller variant.)

    //  arrows
    .init("gets", "\u{2190}"),  // ←
    .init("to", "\u{2192}"),  // →
    .init("iff", "\u{27FA}"),  // ⟺
    // delimiters
    .init("lbrace", "\u{007B}"),  // {
    .init("rbrace", "\u{007D}"),  // }
    .init("lbrack", "\u{005B}"),  // [
    .init("rbrack", "\u{005D}"),  // ]
    .init("vert", "\u{007C}"),  // |
    .init("Vert", "\u{2016}"),  // ‖

    // Math-mode versions of text symbols. It's generally preferable to use the
    // universal symbols instead. So it's commented out.

    // .init("mathdollar", "\u{0024}"),  // $
    // .init("mathellipsis", "\u{2026}"),  // …
    // .init("mathparagraph", "\u{00B6}"),  // ¶
    // .init("mathsection", "\u{00A7}"),  // §
    // .init("mathsterling", "\u{00A3}"),  // £
    // .init("mathunderscore", "\u{005F}"),  // _

    // spaces
    .init("quad", "\u{2001}"),
    .init("qquad", "\u{2001}\u{2001}"),
    .init("enspace", "\u{2002}"),
    .init("thickspace", "\u{2004}"),
    .init("medspace", "\u{2005}"),
    .init("thinspace", "\u{2006}"),
  ]
}

private enum AMSCommands {
  static let mathSymbols: Array<NamedSymbol> =
    binaryOperators + largeOperators + binaryRelations + negatedBinaryRelations
    + subsetRelations + inequalities + triangleRelations + arrows + negatedArrows
    + harpoons + greekLetters + hebrewLetters + letterLikeSymbols + delimiters
    + variableSizedDelimiters + dots + angles + miscellaneous + otherVerified

  // total: 23 symbols
  private static let binaryOperators: Array<NamedSymbol> = [
    .init("barwedge", "\u{22BC}"),  // ⊼
    .init("boxdot", "\u{22A1}"),  // ⊡
    .init("boxminus", "\u{229F}"),  // ⊟
    .init("boxplus", "\u{229E}"),  // ⊞
    .init("boxtimes", "\u{22A0}"),  // ⊠
    .init("Cap", "\u{22D2}"),  // ⋒
    .init("centerdot", "\u{22C5}"),  // ⋅
    .init("circledast", "\u{229B}"),  // ⊛
    .init("circledcirc", "\u{229A}"),  // ⊚
    .init("circleddash", "\u{229D}"),  // ⊝
    .init("Cup", "\u{22D3}"),  // ⋓
    .init("curlyvee", "\u{22CE}"),  // ⋎
    .init("curlywedge", "\u{22CF}"),  // ⋏
    .init("divideontimes", "\u{22C7}"),  // ⋇
    .init("dotplus", "\u{2214}"),  // ∔
    .init("doublebarwedge", "\u{2A5E}"),  // ⩞
    .init("intercal", "\u{22BA}"),  // ⊺
    .init("leftthreetimes", "\u{22CB}"),  // ⋋
    .init("ltimes", "\u{22C9}"),  // ⋉
    .init("rightthreetimes", "\u{22CC}"),  // ⋌
    .init("rtimes", "\u{22CA}"),  // ⋊
    // .init("smallsetminus", "\u{2216}"),  // (Provisional. Needs smaller variant.)
    .init("veebar", "\u{22BB}"),  // ⊻
  ]

  // total: 4 symbols
  private static let largeOperators: Array<NamedSymbol> = [
    .init("iint", "\u{222C}", tag: .mathOperator),  // ∬
    .init("iiint", "\u{222D}", tag: .mathOperator),  // ∭
    .init("iiiint", "\u{2A0C}", tag: .mathOperator),  // ⨌
    .init("idotsint", "\u{222B}\u{22EF}\u{222B}", tag: .mathOperator),  // ∫⋯∫
  ]

  // total: 34 symbols
  private static let binaryRelations: Array<NamedSymbol> = [
    .init("approxeq", "\u{224A}"),  // ≊
    .init("backepsilon", "\u{03F6}"),  // ϶
    .init("backsim", "\u{223D}"),  // ∽
    .init("backsimeq", "\u{22CD}"),  // ⋍
    .init("because", "\u{2235}"),  // ∵
    .init("between", "\u{226C}"),  // ≬
    .init("Bumpeq", "\u{224E}"),  // ≎
    .init("bumpeq", "\u{224F}"),  // ≏
    .init("circeq", "\u{2257}"),  // ≗
    .init("curlyeqprec", "\u{22DE}"),  // ⋞
    .init("curlyeqsucc", "\u{22DF}"),  // ⋟
    .init("doteqdot", "\u{2251}"),  // ≑
    .init("eqcirc", "\u{2256}"),  // ≖
    .init("fallingdotseq", "\u{2252}"),  // ≒
    .init("multimap", "\u{22B8}"),  // ⊸
    .init("pitchfork", "\u{22D4}"),  // ⋔
    .init("precapprox", "\u{2AB7}"),  // ⪷
    .init("preccurlyeq", "\u{227C}"),  // ≼
    .init("precsim", "\u{227E}"),  // ≾
    .init("risingdotseq", "\u{2253}"),  // ≓
    // .init("shortmid", "\u{2223}"), // (Provisional. Needs shorter variant.)
    // .init("shortparallel", "\u{2225}"), // (Provisional. Needs shorter variant.)
    // .init("smallfrown", "\u{2322}"),  // (Provisional. Needs smaller variant.)
    // .init("smallsmile", "\u{2323}"),  // (Provisional. Needs smaller variant.)
    .init("succapprox", "\u{2AB8}"),  // ⪸
    .init("succcurlyeq", "\u{227D}"),  // ≽
    .init("succsim", "\u{227F}"),  // ≿
    .init("therefore", "\u{2234}"),  // ∴
    // .init("thickapprox", "\u{2248}"),  // ≈ (Provisional. Needs thicker variant.)
    // .init("thicksim", "\u{223C}"),  // ∼ (Provisional. Needs thicker variant.)
    // .init("varpropto", "\u{221D}"),  // ∝ (Provisional. Needs a variant.)
    .init("Vdash", "\u{22A9}"),  // ⊩
    .init("vDash", "\u{22A8}"),  // ⊨
    .init("Vvdash", "\u{22AA}"),  // ⊪
  ]

  // total: 17 symbols
  private static let negatedBinaryRelations: Array<NamedSymbol> = [
    .init("ncong", "\u{2247}"),  // ≇
    .init("nmid", "\u{2224}"),  // ∤
    .init("nparallel", "\u{2226}"),  // ∦
    .init("nprec", "\u{2280}"),  // ⊀
    .init("npreceq", "\u{22E0}"),  // ⋠
    // .init("nshortmid", "\u{E006}"),  // PUA block U+E006
    // .init("nshortparallel", "\u{E007}"),  // PUA block U+E007
    .init("nsim", "\u{2241}"),  // ≁
    .init("nsucc", "\u{2281}"),  // ⊁
    .init("nsucceq", "\u{22E1}"),  // ⋡
    .init("nvDash", "\u{22AD}"),  // ⊭
    .init("nvdash", "\u{22AC}"),  // ⊬
    .init("nVDash", "\u{22AF}"),  // ⊯
    .init("precnapprox", "\u{2AB9}"),  // ⪹
    .init("precnsim", "\u{22E8}"),  // ⋨
    .init("succnapprox", "\u{2ABA}"),  // ⪺
    .init("succnsim", "\u{22E9}"),  // ⋩
  ]

  // total: 17 symbols
  private static let subsetRelations: Array<NamedSymbol> = [
    .init("nsubseteq", "\u{2288}"),  // ⊈
    .init("nsupseteq", "\u{2289}"),  // ⊉
    // .init("nsupseteqq", "\u{E018}"),  // PUA block U+E018
    // .init("sqsubset", "\u{228F}"),  // ⊏ (duplicated in latexsym package)
    // .init("sqsupset", "\u{2290}"),  // ⊐ (duplicated in latexsym package)
    .init("Subset", "\u{22D0}"),  // ⋐
    .init("subseteqq", "\u{2AC5}"),  // ⫅
    .init("subsetneq", "\u{228A}"),  // ⊊
    .init("subsetneqq", "\u{2ACB}"),  // ⫋
    .init("Supset", "\u{22D1}"),  // ⋑
    .init("supseteqq", "\u{2AC6}"),  // ⫆
    .init("supsetneq", "\u{228B}"),  // ⊋
    .init("supsetneqq", "\u{2ACC}"),  // ⫌
    // .init("varsubsetneq", "\u{E01A}"),  // PUA block U+E01A
    // .init("varsubsetneqq", "\u{E017}"),  // PUA block U+E017
    // .init("varsupsetneq", "\u{E01B}"),  // PUA block U+E01B
    // .init("varsupsetneqq", "\u{E019}"),  // PUA block U+E019
  ]

  // total: 38 symbols
  private static let inequalities: Array<NamedSymbol> = [
    .init("eqslantgtr", "\u{2A96}"),  // ⪖
    .init("eqslantless", "\u{2A95}"),  // ⪕
    .init("geqq", "\u{2267}"),  // ≧
    .init("geqslant", "\u{2A7E}"),  // ⩾
    .init("ggg", "\u{22D9}"),  // ⋙
    .init("gnapprox", "\u{2A8A}"),  // ⪊
    .init("gneq", "\u{2A88}"),  // ⪈
    .init("gneqq", "\u{2269}"),  // ≩
    .init("gnsim", "\u{22E7}"),  // ⋧
    .init("gtrapprox", "\u{2A86}"),  // ⪆
    .init("gtrdot", "\u{22D7}"),  // ⋗
    .init("gtreqless", "\u{22DB}"),  // ⋛
    .init("gtreqqless", "\u{2A8C}"),  // ⪌
    .init("gtrless", "\u{2277}"),  // ≷
    .init("gtrsim", "\u{2273}"),  // ≳
    // .init("gvertneqq", "\u{E00D}"), // PUA block U+E00D
    .init("leqq", "\u{2266}"),  // ≦
    .init("leqslant", "\u{2A7D}"),  // ⩽
    .init("lessapprox", "\u{2A85}"),  // ⪅
    .init("lessdot", "\u{22D6}"),  // ⋖
    .init("lesseqgtr", "\u{22DA}"),  // ⋚
    .init("lesseqqgtr", "\u{2A8B}"),  // ⪋
    .init("lessgtr", "\u{2276}"),  // ≶
    .init("lesssim", "\u{2272}"),  // ≲
    .init("lll", "\u{22D8}"),  // ⋘
    .init("lnapprox", "\u{2A89}"),  // ⪉
    .init("lneq", "\u{2A87}"),  // ⪇
    .init("lneqq", "\u{2268}"),  // ≨
    .init("lnsim", "\u{22E6}"),  // ⋦
    // .init("lvertneqq", "\u{E00C}"),  // PUA block U+E00C
    .init("ngeq", "\u{2271}"),  // ≱
    // .init("ngeqq", "\u{E00E}"),  // PUA block U+E00E
    // .init("ngeqslant", "\u{E00F}"),  // PUA block U+E00F
    .init("ngtr", "\u{226F}"),  // ≯
    .init("nleq", "\u{2270}"),  // ≰
    // .init("nleqq", "\u{E011}"),  // PUA block U+E011
    // .init("nleqslant", "\u{E010}"),  // PUA block U+E010
    .init("nless", "\u{226E}"),  // ≮
  ]

  // total: 11 symbols
  private static let triangleRelations: Array<NamedSymbol> = [
    .init("blacktriangleleft", "\u{25C2}"),  // ◂
    .init("blacktriangleright", "\u{25B8}"),  // ▸
    .init("ntriangleleft", "\u{22EA}"),  // ⋪
    .init("ntrianglelefteq", "\u{22EC}"),  // ⋬
    .init("ntriangleright", "\u{22EB}"),  // ⋫
    .init("ntrianglerighteq", "\u{22ED}"),  // ⋭
    .init("trianglelefteq", "\u{22B4}"),  // ⊴
    .init("triangleq", "\u{225C}"),  // ≜
    .init("trianglerighteq", "\u{22B5}"),  // ⊵
    .init("vartriangleleft", "\u{22B2}"),  // ⊲
    .init("vartriangleright", "\u{22B3}"),  // ⊳
  ]

  // total: 23 symbols
  private static let arrows: Array<NamedSymbol> = [
    .init("circlearrowleft", "\u{21BA}"),  // ↺
    .init("circlearrowright", "\u{21BB}"),  // ↻
    .init("curvearrowleft", "\u{21B6}"),  // ↶
    .init("curvearrowright", "\u{21B7}"),  // ↷
    .init("dashleftarrow", "\u{21E0}"),  // ⇠
    .init("dashrightarrow", "\u{21E2}"),  // ⇢
    .init("downdownarrows", "\u{21CA}"),  // ⇊
    .init("leftarrowtail", "\u{21A2}"),  // ↢
    .init("leftleftarrows", "\u{21C7}"),  // ⇇
    .init("leftrightarrows", "\u{21C6}"),  // ⇆
    .init("leftrightsquigarrow", "\u{21AD}"),  // ↭
    .init("Lleftarrow", "\u{21DA}"),  // ⇚
    .init("looparrowleft", "\u{21AB}"),  // ↫
    .init("looparrowright", "\u{21AC}"),  // ↬
    .init("Lsh", "\u{21B0}"),  // ↰
    .init("rightarrowtail", "\u{21A3}"),  // ↣
    .init("rightleftarrows", "\u{21C4}"),  // ⇄
    .init("rightrightarrows", "\u{21C9}"),  // ⇉
    .init("rightsquigarrow", "\u{21DD}"),  // ⇝
    .init("Rsh", "\u{21B1}"),  // ↱
    .init("twoheadleftarrow", "\u{219E}"),  // ↞
    .init("twoheadrightarrow", "\u{21A0}"),  // ↠
    .init("upuparrows", "\u{21C8}"),  // ⇈
  ]

  // total: 6 symbols
  private static let negatedArrows: Array<NamedSymbol> = [
    .init("nLeftarrow", "\u{21CD}"),  // ⇍
    .init("nleftarrow", "\u{219A}"),  // ↚
    .init("nLeftrightarrow", "\u{21CE}"),  // ⇎
    .init("nleftrightarrow", "\u{21AE}"),  // ↮
    .init("nRightarrow", "\u{21CF}"),  // ⇏
    .init("nrightarrow", "\u{219B}"),  // ↛
  ]

  // total: 6 symbols
  private static let harpoons: Array<NamedSymbol> = [
    .init("downharpoonleft", "\u{21C3}"),  // ⇃
    .init("downharpoonright", "\u{21C2}"),  // ⇂
    .init("leftrightharpoons", "\u{21CB}"),  // ⇋
    // .init("rightleftharpoons", "\u{21CC}"),  // ⇌ (duplicated in LaTeX core)
    .init("upharpoonleft", "\u{21BF}"),  // ↿
    .init("upharpoonright", "\u{21BE}"),  // ↾
  ]

  // total: 2 symbols
  private static let greekLetters: Array<NamedSymbol> = [
    .init("digamma", "\u{03DD}"),  // ϝ
    .init("varkappa", "\u{03F0}"),  // ϰ
  ]

  // total: 3 symbols
  private static let hebrewLetters: Array<NamedSymbol> = [
    .init("beth", "\u{2136}"),  // ℶ
    .init("gimel", "\u{2137}"),  // ℷ
    .init("daleth", "\u{2138}"),  // ℸ
  ]

  // total: 9 symbols
  private static let letterLikeSymbols: Array<NamedSymbol> = [
    .init("Bbbk", "\u{1D55C}"),
    .init("circledR", "\u{00AE}"),  // ® (turned off in text mode)
    .init("circledS", "\u{24C8}"),  // Ⓢ
    .init("complement", "\u{2201}"),  // ∁
    .init("Finv", "\u{2132}"),  // Ⅎ
    .init("Game", "\u{2141}"),  // ⅁
    // .init("hbar", "\u{210F}"),  // ℏ (duplicated in LaTeX core)
    .init("hslash", "\u{210F}"),  // ℏ
    .init("nexists", "\u{2204}"),  // ∄
  ]

  // total: 4 symbols
  private static let delimiters: Array<NamedSymbol> = [
    .init("ulcorner", "\u{231C}"),  // ⌜
    .init("llcorner", "\u{231E}"),  // ⌞
    .init("urcorner", "\u{231D}"),  // ⌝
    .init("lrcorner", "\u{231F}"),  // ⌟
  ]

  // total: 4 symbols
  private static let variableSizedDelimiters: Array<NamedSymbol> = [
    .init("lvert", "\u{007C}"),  // ∣
    .init("lVert", "\u{2016}"),  // ∥
    .init("rvert", "\u{007C}"),  // ∣
    .init("rVert", "\u{2016}"),  // ∥
  ]

  // total: 7 symbols
  private static let dots: Array<NamedSymbol> = [
    // \because, \therefore defined in `binaryRelations`
    .init("dotsb", "\u{22EF}"),  // ⋯
    .init("dotsc", "\u{2026}"),  // …
    .init("dotsi", "\u{22EF}"),  // ⋯
    .init("dotsm", "\u{22EF}"),  // ⋯
    .init("dotso", "\u{2026}"),  // …
  ]

  // Table 327, total: 3 symbols
  private static let angles: Array<NamedSymbol> = [
    // .init("angle", "\u{2220}"),  // ∠ (duplicated in LaTeX core)
    .init("measuredangle", "\u{2221}"),  // ∡
    .init("sphericalangle", "\u{2222}"),  // ∢
  ]

  // Table 335, total: 15 symbols.
  private static let miscellaneous: Array<NamedSymbol> = [
    .init("backprime", "\u{2035}"),  // ‵
    .init("bigstar", "\u{2605}"),  // ★
    .init("blacklozenge", "\u{29EB}"),  // ⧫
    .init("blacksquare", "\u{25A0}"),  // ■
    .init("blacktriangle", "\u{25B4}"),  // ▴
    .init("blacktriangledown", "\u{25BE}"),  // ▾
    .init("diagdown", "\u{27CD}"),  // ⟍
    .init("diagup", "\u{27CB}"),  // ⟋
    .init("eth", "\u{00F0}"),  // ð (turned off in text mode)
    .init("lozenge", "\u{25CA}"),  // ◊
    // .init("mho", "\u{2127}"),  // ℧ (duplicated in LaTeX core)
    .init("square", "\u{25A1}"),  // □
    .init("triangledown", "\u{25BF}"),  // ▿
    .init("varnothing", "\u{2300}"),  // ⌀
    .init("vartriangle", "\u{25B3}"),
  ]

  private static let otherVerified: Array<NamedSymbol> = [
    .init("checkmark", "\u{2713}"),  // ✓ (turned off in text mode)
    .init("maltese", "\u{2720}"),  // ✠ (turned off in text mode)
    .init("yen", "\u{00A5}"),  // ¥ (turned off in text mode)
    //
    .init("Doteq", "\u{2251}"),  // ≑
    .init("doublecap", "\u{22D2}"),  // ⋒
    .init("doublecup", "\u{22D3}"),  // ⋓
    .init("eqsim", "\u{2242}"),  // ≂
    .init("gggtr", "\u{22D9}"),  // ⋙
    .init("llless", "\u{22D8}"),  // ⋘
    // .init("nsubseteqq", "\u{E016}"),  // PUA block U+E016
    .init("nVdash", "\u{22AE}"),  // ⊮
    .init("precneqq", "\u{2AB5}"),  // ⪵
    .init("restriction", "\u{21BE}"),  // ↾
    .init("Rrightarrow", "\u{21DB}"),  // ⇛
    .init("succneqq", "\u{2AB6}"),  // ⪶
    // arrows
    .init("impliedby", "\u{27F8}"),  // ⟸
    .init("implies", "\u{27F9}"),  // ⟹
  ]
}

private enum OtherCommands {
  static let universalSymbol: Array<NamedSymbol> = [
    .init("QED", "\u{220E}", contentMode: .universal)  // ∎
  ]

  static let mathSymbols: Array<NamedSymbol> = [
    // primes
    .init("dprime", "\u{2033}"),  // ″
    .init("trprime", "\u{2034}"),  // ‴
    .init("qprime", "\u{2057}"),  // ⁗
    .init("backdprime", "\u{2036}"),  // ‶
    .init("backtrprime", "\u{2037}"),  // ‷
    //
    .init("diameter", "\u{2300}"),  // ⌀
    // join
    .init("fullouterjoin", "\u{27D7}"),  // ⟗
    .init("leftouterjoin", "\u{27D5}"),  // ⟕
    .init("rightouterjoin", "\u{27D6}"),  // ⟖
    // integrals
    .init("oiint", "\u{222F}"),  // ∯
    .init("oiiint", "\u{2230}"),  // ∰
  ]
}

// It's not easy to find the unicode for these.
// Let's keep them in case we need them in the future.

/*
// Script
.init("scrA", "\u{1D49C}"),  // 𝒜
.init("scrB", "\u{212C}"),  // ℬ
.init("scrC", "\u{1D49E}"),  // 𝒞
.init("scrD", "\u{1D49F}"),  // 𝒟
.init("scrE", "\u{02130}"),  // ℰ
.init("scrF", "\u{02131}"),  // ℱ
.init("scrG", "\u{1D4A2}"),  // 𝒢
.init("scrH", "\u{210B}"),  // ℋ
.init("scrI", "\u{2110}"),  // ℐ
.init("scrJ", "\u{1D4A5}"),  // 𝒥
.init("scrK", "\u{1D4A6}"),  // 𝒦
.init("scrL", "\u{2112}"),  // ℒ
.init("scrM", "\u{2133}"),  // ℳ
.init("scrN", "\u{1D4A9}"),  // 𝒩
.init("scrO", "\u{1D4AA}"),  // 𝒪
.init("scrP", "\u{1D4AB}"),  // 𝒫
.init("scrQ", "\u{1D4AC}"),  // 𝒬
.init("scrR", "\u{211B}"),  // ℜ
.init("scrS", "\u{1D4AE}"),  // 𝒮
.init("scrT", "\u{1D4AF}"),  // 𝒯
.init("scrU", "\u{1D4B0}"),  // 𝒰
.init("scrV", "\u{1D4B1}"),  // 𝒱
.init("scrW", "\u{1D4B2}"),  // 𝒲
.init("scrX", "\u{1D4B3}"),  // 𝒳
.init("scrY", "\u{1D4B4}"),  // 𝒴
.init("scrZ", "\u{1D4B5}"),  // 𝒵
.init("scra", "\u{1D4B6}"),  // 𝒶
.init("scrb", "\u{1D4B7}"),  // 𝒷
.init("scrc", "\u{1D4B8}"),  // 𝒸
.init("scrd", "\u{1D4B9}"),  // 𝒹
.init("scre", "\u{212F}"),  // ℯ
.init("scrf", "\u{1D4BB}"),  // 𝒻
.init("scrg", "\u{210A}"),  // ℊ
.init("scrh", "\u{1D4BD}"),  // 𝒽
.init("scri", "\u{1D4BE}"),  // 𝒾
.init("scrj", "\u{1D4BF}"),  // 𝒿
.init("scrk", "\u{1D4C0}"),  // 𝓀
.init("scrl", "\u{1D4C1}"),  // 𝓁
.init("scrm", "\u{1D4C2}"),  // 𝓂
.init("scrn", "\u{1D4C3}"),  // 𝓃
.init("scro", "\u{02134}"),  // ℴ
.init("scrp", "\u{1D4C5}"),  // 𝓅
.init("scrq", "\u{1D4C6}"),  // 𝓆
.init("scrr", "\u{1D4C7}"),  // 𝓇
.init("scrs", "\u{1D4C8}"),  // 𝓈
.init("scrt", "\u{1D4C9}"),  // 𝓉
.init("scru", "\u{1D4CA}"),  // 𝓊
.init("scrv", "\u{1D4CB}"),  // 𝓋
.init("scrw", "\u{1D4CC}"),  // 𝓌
.init("scrx", "\u{1D4CD}"),  // 𝓍
.init("scry", "\u{1D4CE}"),  // 𝓎
.init("scrz", "\u{1D4CF}"),  // 𝓏
// Fraktur
.init("frakA", "\u{1D504}"),  // 𝔄
.init("frakB", "\u{1D505}"),  // 𝔅
.init("frakC", "\u{212D}"),  // ℭ
.init("frakD", "\u{1D507}"),  // 𝔇
.init("frakE", "\u{1D508}"),  // 𝔈
.init("frakF", "\u{1D509}"),  // 𝔉
.init("frakG", "\u{1D50A}"),  // 𝔊
.init("frakH", "\u{210C}"),  // ℌ
// frakI is Im
.init("frakJ", "\u{1D50D}"),  // 𝔍
.init("frakK", "\u{1D50E}"),  // 𝔎
.init("frakL", "\u{1D50F}"),  // 𝔏
.init("frakM", "\u{1D510}"),  // 𝔐
.init("frakN", "\u{1D511}"),  // 𝔑
.init("frakO", "\u{1D512}"),  // 𝔒
.init("frakP", "\u{1D513}"),  // 𝔓
.init("frakQ", "\u{1D514}"),  // 𝔔
// frakR is Re
.init("frakS", "\u{1D516}"),  // 𝔖
.init("frakT", "\u{1D517}"),  // 𝔗
.init("frakU", "\u{1D518}"),  // 𝔘
.init("frakV", "\u{1D519}"),  // 𝔙
.init("frakW", "\u{1D51A}"),  // 𝔚
.init("frakX", "\u{1D51B}"),  // 𝔛
.init("frakY", "\u{1D51C}"),  // 𝔜
.init("frakZ", "\u{2128}"),  // ℨ
.init("fraka", "\u{1D51E}"),  // 𝔞
.init("frakb", "\u{1D51F}"),  // 𝔟
.init("frakc", "\u{1D520}"),  // 𝔠
.init("frakd", "\u{1D521}"),  // 𝔡
.init("frake", "\u{1D522}"),  // 𝔢
.init("frakf", "\u{1D523}"),  // 𝔣
.init("frakg", "\u{1D524}"),  // 𝔤
.init("frakh", "\u{1D525}"),  // 𝔥
.init("fraki", "\u{1D526}"),  // 𝔦
.init("frakj", "\u{1D527}"),  // 𝔧
.init("frakk", "\u{1D528}"),  // 𝔨
.init("frakl", "\u{1D529}"),  // 𝔩
.init("frakm", "\u{1D52A}"),  // 𝔪
.init("frakn", "\u{1D52B}"),  // 𝔫
.init("frako", "\u{1D52C}"),  // 𝔬
.init("frakp", "\u{1D52D}"),  // 𝔭
.init("frakq", "\u{1D52E}"),  // 𝔮
.init("frakr", "\u{1D52F}"),  // 𝔯
.init("fraks", "\u{1D530}"),  // 𝔰
.init("frakt", "\u{1D531}"),  // 𝔱
.init("fraku", "\u{1D532}"),  // 𝔲
.init("frakv", "\u{1D533}"),  // 𝔳
.init("frakw", "\u{1D534}"),  // 𝔴
.init("frakx", "\u{1D535}"),  // 𝔵
.init("fraky", "\u{1D536}"),  // 𝔶
.init("frakz", "\u{1D537}"),  // 𝔷
// Bbb
.init("BbbA", "\u{1D538}"),  // 𝔸
.init("BbbB", "\u{1D539}"),  // 𝔹
.init("BbbC", "\u{2102}"),  // ℂ
.init("BbbD", "\u{1D53B}"),  // 𝔻
.init("BbbE", "\u{1D53C}"),  // 𝔼
.init("BbbF", "\u{1D53D}"),  // 𝔽
.init("BbbG", "\u{1D53E}"),  // 𝔾
.init("BbbH", "\u{210D}"),  // ℍ
.init("BbbI", "\u{1D540}"),  // 𝕀
.init("BbbJ", "\u{1D541}"),  // 𝕁
.init("BbbK", "\u{1D542}"),  // 𝕂
.init("BbbL", "\u{1D543}"),  // 𝕃
.init("BbbM", "\u{1D544}"),  // 𝕄
.init("BbbN", "\u{2115}"),  // ℕ
.init("BbbO", "\u{1D546}"),  // 𝕆
.init("BbbP", "\u{2119}"),  // ℙ
.init("BbbQ", "\u{211A}"),  // ℚ
.init("BbbR", "\u{211D}"),  // ℝ
.init("BbbS", "\u{1D54A}"),  // 𝕊
.init("BbbT", "\u{1D54B}"),  // 𝕋
.init("BbbU", "\u{1D54C}"),  // 𝕌
.init("BbbV", "\u{1D54D}"),  // 𝕍
.init("BbbW", "\u{1D54E}"),  // 𝕎
.init("BbbX", "\u{1D54F}"),  // 𝕏
.init("BbbY", "\u{1D550}"),  // 𝕐
.init("BbbZ", "\u{2124}"),  // ℤ
.init("Bbba", "\u{1D552}"),  // 𝕒
.init("Bbbb", "\u{1D553}"),  // 𝕓
.init("Bbbc", "\u{1D554}"),  // 𝕔
.init("Bbbd", "\u{1D555}"),  // 𝕕
.init("Bbbe", "\u{1D556}"),  // 𝕖
.init("Bbbf", "\u{1D557}"),  // 𝕗
.init("Bbbg", "\u{1D558}"),  // 𝕘
.init("Bbbh", "\u{1D559}"),  // 𝕙
.init("Bbbi", "\u{1D55A}"),  // 𝕚
.init("Bbbj", "\u{1D55B}"),  // 𝕛
.init("Bbbk", "\u{1D55C}"),  // 𝕜
.init("Bbbl", "\u{1D55D}"),  // 𝕝
.init("Bbbm", "\u{1D55E}"),  // 𝕞
.init("Bbbn", "\u{1D55F}"),  // 𝕟
.init("Bbbo", "\u{1D560}"),  // 𝕠
.init("Bbbp", "\u{1D561}"),  // 𝕡
.init("Bbbq", "\u{1D562}"),  // 𝕢
.init("Bbbr", "\u{1D563}"),  // 𝕣
.init("Bbbs", "\u{1D564}"),  // 𝕤
.init("Bbbt", "\u{1D565}"),  // 𝕥
.init("Bbbu", "\u{1D566}"),  // 𝕦
.init("Bbbv", "\u{1D567}"),  // 𝕧
.init("Bbbw", "\u{1D568}"),  // 𝕨
.init("Bbbx", "\u{1D569}"),  // 𝕩
.init("Bbby", "\u{1D56A}"),  // 𝕪
.init("Bbbz", "\u{1D56B}"),  // 𝕫
 */
