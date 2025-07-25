import Foundation
import Testing

@testable import SwiftRohan

struct NodeStoreUtilsTests {
  @Test
  func classSet() {
    let classes = Set(NodeStoreUtils.registeredClasses.map(\.type))
    #expect(classes.count == 26)
    #expect(classes.count == NodeType.allCases.count - 5)
    #expect(NodeStoreUtils.registeredClasses.count == classes.count)
  }

  /// Tag set must be stable and can only expand but not shrink.
  @Test
  func tagSet() {
    let tags = NodeStoreUtils.registeredTags.keys.map { ($0.lowercased(), $0) }
      .sorted(by: { lhs, rhs in
        if lhs.0 == rhs.0 { return lhs.1 < rhs.1 }
        return lhs.0 < rhs.0
      })
      .map(\.1)

    let expected = [
      "acute", "aleph", "align", "align*", "aligned", "alpha", "amalg", "angle", "approx",
      "approxeq", "arccos", "arcsin", "arctan", "arg", "ast", "asymp", "atop", "attach",

      "backdprime", "backepsilon", "backprime", "backsim", "backsimeq", "backslash",
      "backtrprime", "bar", "barwedge", "Bbbk", "because", "beta", "beth", "between",
      "bigcap", "bigcirc", "bigcup", "bigodot", "bigoplus", "bigotimes", "bigsqcup",
      "bigstar", "bigtriangledown", "bigtriangleup", "biguplus", "bigvee", "bigwedge",
      "binom", "blacklozenge", "blacksquare", "blacktriangle", "blacktriangledown",
      "blacktriangleleft", "blacktriangleright", "Bmatrix", "bmatrix", "bmod", "bot",
      "bowtie", "Box", "boxdot", "boxminus", "boxplus", "boxtimes", "breve", "bullet",
      "Bumpeq", "bumpeq",

      "Cap", "cap", "cases", "cdot", "cdotp", "cdots", "centerdot", "cfrac", "check",
      "checkmark", "chi", "circ", "circeq", "circlearrowleft", "circlearrowright",
      "circledast", "circledcirc", "circleddash", "circledR", "circledS", "clubsuit",
      "colon", "complement", "cong", "coprod", "copyright", "corollary", "cos", "cosh",
      "cot", "coth", "counter", "csc", "Cup", "cup", "curlyeqprec", "curlyeqsucc",
      "curlyvee", "curlywedge", "curvearrowleft", "curvearrowright",

      "dag", "dagger", "daleth", "dashleftarrow", "dashrightarrow", "dashv", "dbinom",
      "ddag", "ddagger", "ddddot", "dddot", "ddot", "ddots", "deg", "Delta", "delta",
      "det", "dfrac", "diagdown", "diagup", "diameter", "Diamond", "diamond",
      "diamondsuit", "digamma", "dim", "displaymath", "displaystyle", "div",
      "divideontimes", "document", "dot", "Doteq", "doteq", "doteqdot", "dotplus",
      "dotsb", "dotsc", "dotsi", "dotsm", "dotso", "doublebarwedge", "doublecap",
      "doublecup", "Downarrow", "downarrow", "downdownarrows", "downharpoonleft",
      "downharpoonright", "dprime",

      "ell", "emph", "emptyset", "enspace", "enumerate", "epsilon", "eqcirc", "eqsim",
      "eqslantgtr", "eqslantless", "equation", "equiv", "eta", "eth", "exists", "exp",

      "fallingdotseq", "Finv", "flat", "forall", "frac", "frown", "fullouterjoin",

      "Game", "Gamma", "gamma", "gather", "gather*", "gathered", "gcd", "ge", "geq",
      "geqq", "geqslant", "gets", "gg", "ggg", "gggtr", "gimel", "gnapprox", "gneq",
      "gneqq", "gnsim", "grave", "gtrapprox", "gtrdot", "gtreqless", "gtreqqless",
      "gtrless", "gtrsim",

      "hat", "hbar", "heartsuit", "hom", "hookleftarrow", "hookrightarrow", "hslash",

      "idotsint", "iff", "iiiint", "iiint", "iint", "Im", "imath", "impliedby", "implies",
      "in", "inf", "infty", "injlim", "inlinemath", "int", "intercal", "intop", "iota",
      "itemize",

      "jmath", "Join",

      "kappa", "ker",

      "Lambda", "lambda", "land", "langle", "lbrace", "lbrack", "lceil", "ldotp", "ldots",
      "le", "leadsto", "Leftarrow", "leftarrow", "leftarrowtail", "leftharpoondown",
      "leftharpoonup", "leftleftarrows", "leftouterjoin", "leftright", "Leftrightarrow",
      "leftrightarrow", "leftrightarrows", "leftrightharpoons", "leftrightsquigarrow",
      "leftthreetimes", "lemma", "leq", "leqq", "leqslant", "lessapprox", "lessdot",
      "lesseqgtr", "lesseqqgtr", "lessgtr", "lesssim", "lfloor", "lg", "lgroup", "lhd",
      "lim", "liminf", "limits", "limsup", "linebreak", "ll", "llcorner", "Lleftarrow",
      "lll", "llless", "lmoustache", "ln", "lnapprox", "lneq", "lneqq", "lnot", "lnsim",
      "log", "Longleftarrow", "longleftarrow", "Longleftrightarrow", "longleftrightarrow",
      "longmapsto", "Longrightarrow", "longrightarrow", "looparrowleft", "looparrowright",
      "lor", "lozenge", "lrcorner", "Lsh", "ltimes", "lVert", "lvert",

      "maltese", "mapsto", "mathbb", "mathbf", "mathbin", "mathcal", "mathclose",
      "mathfrak", "mathinner", "mathit", "mathop", "mathopen", "mathord", "mathpunct",
      "mathrel", "mathring", "mathrm", "mathsf", "mathtt", "matrix", "max",
      "measuredangle", "medspace", "mho", "mid", "min", "models", "mp", "mu", "multimap",
      "multline", "multline*",

      "nabla", "natural", "ncong", "ne", "nearrow", "neg", "neq", "nexists", "ngeq",
      "ngtr", "ni", "nLeftarrow", "nleftarrow", "nLeftrightarrow", "nleftrightarrow",
      "nleq", "nless", "nmid", "nolimits", "notin", "nparallel", "nprec", "npreceq",
      "nRightarrow", "nrightarrow", "nsim", "nsubseteq", "nsucc", "nsucceq", "nsupseteq",
      "ntriangleleft", "ntrianglelefteq", "ntriangleright", "ntrianglerighteq", "nu",
      "nVDash", "nVdash", "nvDash", "nvdash", "nwarrow",

      "odot", "oiiint", "oiint", "oint", "Omega", "omega", "ominus", "operatorname",
      "oplus", "oslash", "otimes", "overbar", "overbrace", "overbracket", "overleftarrow",
      "overleftrightarrow", "overline", "overparen", "overrightarrow", "overset", "owns",

      "P", "paragraph", "parallel", "parlist", "partial", "perp", "Phi", "phi", "Pi",
      "pi", "pitchfork", "pm", "pmatrix", "pmod", "pounds", "Pr", "prec", "precapprox",
      "preccurlyeq", "preceq", "precnapprox", "precneqq", "precnsim", "precsim", "prime",
      "prod", "projlim", "proof", "propto", "Psi", "psi",

      "qprime", "qquad", "quad",

      "rangle", "rbrace", "rbrack", "rceil", "Re", "restriction", "rfloor", "rgroup",
      "rhd", "rho", "Rightarrow", "rightarrow", "rightarrowtail", "rightharpoondown",
      "rightharpoonup", "rightleftarrows", "rightleftharpoons", "rightouterjoin",
      "rightrightarrows", "rightsquigarrow", "rightthreetimes", "risingdotseq",
      "rmoustache", "Rrightarrow", "Rsh", "rtimes", "rVert", "rvert",

      "S", "scriptscriptstyle", "scriptstyle", "searrow", "sec", "section", "section*",
      "setminus", "sharp", "Sigma", "sigma", "sim", "simeq", "sin", "sinh", "smallint",
      "smallmatrix", "smile", "spadesuit", "sphericalangle", "sqcap", "sqcup", "sqrt",
      "sqsubset", "sqsubseteq", "sqsupset", "sqsupseteq", "square", "stackrel", "star",
      "subsection", "subsection*", "Subset", "subset", "subseteq", "subseteqq",
      "subsetneq", "subsetneqq", "substack", "subsubsection", "subsubsection*", "succ",
      "succapprox", "succcurlyeq", "succeq", "succnapprox", "succneqq", "succnsim",
      "succsim", "sum", "sup", "Supset", "supset", "supseteq", "supseteqq", "supsetneq",
      "supsetneqq", "surd", "swarrow",

      "tan", "tanh", "tau", "tbinom", "text", "textbf", "textit", "textstyle", "texttt",
      "tfrac", "theorem", "therefore", "Theta", "theta", "thickspace", "thinspace",
      "tilde", "times", "to", "top", "triangle", "triangledown", "triangleleft",
      "trianglelefteq", "triangleq", "triangleright", "trianglerighteq", "trprime",
      "twoheadleftarrow", "twoheadrightarrow",

      "ulcorner", "underbrace", "underbracket", "underleftarrow", "underleftrightarrow",
      "underline", "underparen", "underrightarrow", "underset", "unlhd", "unrhd",
      "Uparrow", "uparrow", "Updownarrow", "updownarrow", "upharpoonleft",
      "upharpoonright", "uplus", "Upsilon", "upsilon", "upuparrows", "urcorner",

      "varDelta", "varepsilon", "varinjlim", "varkappa", "varliminf", "varlimsup",
      "varnothing", "varphi", "varpi", "varprojlim", "varrho", "varsigma", "vartheta",
      "vartriangle", "vartriangleleft", "vartriangleright", "Vdash", "vDash", "vdash",
      "vdots", "vec", "vee", "veebar", "Vert", "vert", "Vmatrix", "vmatrix", "Vvdash",

      "wedge", "widebreve", "widecheck", "widehat", "wideoverbar", "widetilde", "wp",
      "wr",

      "xhookleftarrow", "xhookrightarrow", "Xi", "xi", "xLeftarrow", "xleftarrow",
      "xleftharpoondown", "xleftharpoonup", "xLeftrightarrow", "xleftrightarrow",
      "xleftrightharpoons", "xmapsto", "xRightarrow", "xrightarrow", "xrightharpoondown",
      "xrightharpoonup", "xrightleftharpoons",

      "yen",
      "zeta",
    ]

    #expect(tags.count == 631)
    let unexpected = tags.filter { !expected.contains($0) }
    #expect(unexpected.isEmpty, " Unexpected tags: \(unexpected)")
    let missing = expected.filter { !tags.contains($0) }
    #expect(missing.isEmpty, " Missing tags: \(missing)")
    #expect(tags == expected)
  }
}
