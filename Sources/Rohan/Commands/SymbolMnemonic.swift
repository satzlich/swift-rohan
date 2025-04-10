// Copyright 2024-2025 Lie Yan

struct SymbolMnemonic {
  let command: String
  let unicode: String

  init(_ command: String, _ unicode: String) {
    self.command = command
    self.unicode = unicode
  }
}

/// Symbols that works in Text body and Math list.
enum UniversalSymbols {
  static let allCases: [SymbolMnemonic] = [
    .init("copyright", "\u{00A9}"),  // ©
    .init("dag", "\u{2020}"),  // †
    .init("ddag", "\u{2021}"),  // ‡
    .init("dots", "\u{2026}"),  // …
    .init("P", "\u{00B6}"),  // ¶
    .init("pounds", "\u{00A3}"),  // £
    .init("S", "\u{00A7}"),  // §
  ]
}

enum MathSymbols {
  static let allCases: [SymbolMnemonic] =
    greekLetters + ordinarySymbols + largeOperators + binaryOperators + relationSymbols
    + arrowSymbols

  private static let greekLetters: [SymbolMnemonic] = [
    // Lowercase Greek letters
    .init("alpha", "\u{03B1}"),
    .init("beta", "\u{03B2}"),
    .init("gamma", "\u{03B3}"),
    .init("delta", "\u{03B4}"),
    .init("epsilon", "\u{03F5}"),
    .init("varepsilon", "\u{03B5}"),
    .init("zeta", "\u{03B6}"),
    .init("eta", "\u{03B7}"),
    .init("theta", "\u{03B8}"),
    .init("vartheta", "\u{03D1}"),
    .init("iota", "\u{03B9}"),
    .init("kappa", "\u{03BA}"),
    .init("lambda", "\u{03BB}"),
    .init("mu", "\u{03BC}"),
    .init("nu", "\u{03BD}"),
    .init("xi", "\u{03BE}"),
    .init("o", "\u{03BF}"),
    .init("pi", "\u{03C0}"),
    .init("varpi", "\u{03D6}"),
    .init("rho", "\u{03C1}"),
    .init("varrho", "\u{03F1}"),
    .init("sigma", "\u{03C3}"),
    .init("varsigma", "\u{03C2}"),
    .init("tau", "\u{03C4}"),
    .init("upsilon", "\u{03C5}"),
    .init("phi", "\u{03D5}"),
    .init("varphi", "\u{03C6}"),
    .init("chi", "\u{03C7}"),
    .init("psi", "\u{03C8}"),
    .init("omega", "\u{03C9}"),

    // Uppercase Greek letters
    .init("Gamma", "\u{0393}"),
    .init("Delta", "\u{0394}"),
    .init("Theta", "\u{0398}"),
    .init("Lambda", "\u{039B}"),
    .init("Xi", "\u{039E}"),
    .init("Pi", "\u{03A0}"),
    .init("Sigma", "\u{03A3}"),
    .init("Upsilon", "\u{03A5}"),
    .init("Phi", "\u{03A6}"),
    .init("Psi", "\u{03A8}"),
    .init("Omega", "\u{03A9}"),
  ]

  private static let ordinarySymbols: [SymbolMnemonic] = [
    .init("aleph", "\u{2135}"),  // ℵ
    .init("hbar", "\u{210F}"),  // ℏ
    .init("imath", "\u{0131}"),  // ı
    .init("jmath", "\u{0237}"),  // ȷ
    .init("ell", "\u{2113}"),  // ℓ
    .init("wp", "\u{2118}"),  // ℘
    .init("Re", "\u{211C}"),  // ℜ
    .init("Im", "\u{2111}"),  // ℑ
    .init("partial", "\u{2202}"),  // ∂
    .init("infty", "\u{221E}"),  // ∞

    .init("prime", "\u{2032}"),  // ′
    .init("emptyset", "\u{2205}"),  // ∅
    .init("nabla", "\u{2207}"),  // ∇
    .init("surd", "\u{221A}"),  // √
    .init("top", "\u{22A4}"),  // ⊤
    .init("bot", "\u{22A5}"),  // ⊥
    .init("|", "\u{2016}"),  // ‖
    .init("angle", "\u{2220}"),  // ∠
    .init("triangle", "\u{25B3}"),  // △
    .init("backslash", "\u{2216}"),  // ∖

    .init("forall", "\u{2200}"),  // ∀
    .init("exists", "\u{2203}"),  // ∃
    .init("neg", "\u{00AC}"),  // ¬
    .init("lnot", "\u{00AC}"),  // ¬ (alternative)
    .init("flat", "\u{266D}"),  // ♭
    .init("natural", "\u{266E}"),  // ♮
    .init("sharp", "\u{266F}"),  // ♯
    .init("clubsuit", "\u{2663}"),  // ♣
    .init("diamondsuit", "\u{2662}"),  // ♢
    .init("heartsuit", "\u{2661}"),  // ♡
    .init("spadesuit", "\u{2660}"),  // ♠
  ]

  private static let largeOperators: [SymbolMnemonic] = [
    // Basic large operators
    .init("sum", "\u{2211}"),  // ∑
    .init("prod", "\u{220F}"),  // ∏
    .init("coprod", "\u{2210}"),  // ∐
    .init("int", "\u{222B}"),  // ∫
    .init("oint", "\u{222E}"),  // ∮

    // Set-like large operators
    .init("bigcap", "\u{22C2}"),  // ⋂
    .init("bigcup", "\u{22C3}"),  // ⋃
    .init("bigsqcup", "\u{2A06}"),  // ⨆
    .init("bigvee", "\u{22C1}"),  // ⋁
    .init("bigwedge", "\u{22C0}"),  // ⋀

    // Circled large operators
    .init("bigodot", "\u{2A00}"),  // ⨀
    .init("bigotimes", "\u{2A02}"),  // ⨂
    .init("bigoplus", "\u{2A01}"),  // ⨁
    .init("biguplus", "\u{2A04}"),  // ⨄
  ]

  private static let binaryOperators: [SymbolMnemonic] = [
    // Basic operations
    .init("pm", "\u{00B1}"),  // ±
    .init("mp", "\u{2213}"),  // ∓
    .init("setminus", "\u{2216}"),  // ∖
    .init("cdot", "\u{22C5}"),  // ⋅
    .init("times", "\u{00D7}"),  // ×
    .init("ast", "\u{2217}"),  // ∗
    .init("star", "\u{22C6}"),  // ⋆
    .init("diamond", "\u{22C4}"),  // ⋄
    .init("circ", "\u{2218}"),  // ∘
    .init("bullet", "\u{2219}"),  // ∙
    .init("div", "\u{00F7}"),  // ÷

    // Set operations
    .init("cap", "\u{2229}"),  // ∩
    .init("cup", "\u{222A}"),  // ∪
    .init("uplus", "\u{228E}"),  // ⊎
    .init("sqcap", "\u{2293}"),  // ⊓
    .init("sqcup", "\u{2294}"),  // ⊔
    .init("triangleleft", "\u{25C3}"),  // ◃
    .init("triangleright", "\u{25B9}"),  // ▹
    .init("wr", "\u{2240}"),  // ≀
    .init("bigcirc", "\u{25EF}"),  // ◯
    .init("bigtriangleup", "\u{25B3}"),  // △
    .init("bigtriangledown", "\u{25BD}"),  // ▽

    // Logical/other operations
    .init("vee", "\u{2228}"),  // ∨
    .init("lor", "\u{2228}"),  // ∨ (alias)
    .init("wedge", "\u{2227}"),  // ∧
    .init("land", "\u{2227}"),  // ∧ (alias)
    .init("oplus", "\u{2295}"),  // ⊕
    .init("ominus", "\u{2296}"),  // ⊖
    .init("otimes", "\u{2297}"),  // ⊗
    .init("oslash", "\u{2298}"),  // ⊘
    .init("odot", "\u{2299}"),  // ⊙
    .init("dagger", "\u{2020}"),  // †
    .init("ddagger", "\u{2021}"),  // ‡
    .init("amalg", "\u{2A3F}"),  // ⨿
  ]

  private static let relationSymbols: [SymbolMnemonic] = [
    // Less-than/equal relations
    .init("le", "\u{2264}"),  // ≤
    .init("leq", "\u{2264}"),  // ≤ (alias)
    .init("preceq", "\u{2AAF}"),  // ⪯
    .init("ll", "\u{226A}"),  // ≪
    .init("subset", "\u{2282}"),  // ⊂
    .init("subseteq", "\u{2286}"),  // ⊆
    .init("sqsubseteq", "\u{2291}"),  // ⊑
    .init("in", "\u{2208}"),  // ∈
    .init("vdash", "\u{22A2}"),  // ⊢
    .init("smile", "\u{2323}"),  // ⌣
    .init("frown", "\u{2322}"),  // ⌢
    .init("propto", "\u{221D}"),  // ∝

    // Greater-than/equal relations
    .init("ge", "\u{2265}"),  // ≥
    .init("geq", "\u{2265}"),  // ≥ (alias)
    .init("succ", "\u{227B}"),  // ≻
    .init("succeq", "\u{2AB0}"),  // ⪰
    .init("gg", "\u{226B}"),  // ≫
    .init("supset", "\u{2283}"),  // ⊃
    .init("supseteq", "\u{2287}"),  // ⊇
    .init("sqsupseteq", "\u{2292}"),  // ⊒
    .init("notin", "\u{2209}"),  // ∉
    .init("dashv", "\u{22A3}"),  // ⊣
    .init("mid", "\u{2223}"),  // ∣
    .init("parallel", "\u{2225}"),  // ∥

    // Equivalence relations
    .init("equiv", "\u{2261}"),  // ≡
    .init("sim", "\u{223C}"),  // ∼
    .init("simeq", "\u{2243}"),  // ≃
    .init("asymp", "\u{2248}"),  // ≈
    .init("approx", "\u{2248}"),  // ≈ (alias)
    .init("cong", "\u{2245}"),  // ≅
    .init("bowtie", "\u{22C8}"),  // ⋈
    .init("ni", "\u{220B}"),  // ∋
    .init("owns", "\u{220B}"),  // ∋ (alias)
    .init("models", "\u{22A8}"),  // ⊨
    .init("doteq", "\u{2250}"),  // ≐
    .init("perp", "\u{22A5}"),  // ⊥
  ]

  private static let arrowSymbols: [SymbolMnemonic] = [
    // Basic arrows
    .init("leftarrow", "\u{2190}"),  // ←
    .init("gets", "\u{2190}"),  // ← (alias)
    .init("rightarrow", "\u{2192}"),  // →
    .init("to", "\u{2192}"),  // → (alias)
    .init("Leftarrow", "\u{21D0}"),  // ⇐
    .init("Rightarrow", "\u{21D2}"),  // ⇒
    .init("leftrightarrow", "\u{2194}"),  // ↔
    .init("Leftrightarrow", "\u{21D4}"),  // ⇔
    .init("mapsto", "\u{21A6}"),  // ↦
    .init("hookleftarrow", "\u{21A9}"),  // ↩
    .init("uparrow", "\u{2191}"),  // ↑
    .init("downarrow", "\u{2193}"),  // ↓
    .init("updownarrow", "\u{2195}"),  // ↕
    .init("nearrow", "\u{2197}"),  // ↗
    .init("nwarrow", "\u{2196}"),  // ↖

    // Long arrows
    .init("longleftarrow", "\u{27F5}"),  // ⟵
    .init("Longleftarrow", "\u{27F8}"),  // ⟸
    .init("longrightarrow", "\u{27F6}"),  // ⟶
    .init("Longrightarrow", "\u{27F9}"),  // ⟹
    .init("longleftrightarrow", "\u{27F7}"),  // ⟷
    .init("Longleftrightarrow", "\u{27FA}"),  // ⟺
    .init("longmapsto", "\u{27FC}"),  // ⟼
    .init("hookrightarrow", "\u{21AA}"),  // ↪
    .init("Uparrow", "\u{21D1}"),  // ⇑
    .init("Downarrow", "\u{21D3}"),  // ⇓
    .init("Updownarrow", "\u{21D5}"),  // ⇕
    .init("searrow", "\u{2198}"),  // ↘
    .init("swarrow", "\u{2199}"),  // ↙
  ]
}
