// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct NodeStoreUtilsTests {
  @Test
  func classSet() {
    let classes = Set(NodeStoreUtils.registeredClasses.map(\.type))
    #expect(classes.count == 27)
    #expect(classes.count == NodeType.allCases.count - 5)
    #expect(NodeStoreUtils.registeredClasses.count == classes.count)
  }

  /// Tag set must be stable and can only expand but not shrink.
  @Test
  func tagSet() {
    let tags = NodeStoreUtils.registeredTags.keys.sorted()
    let expected = [
      "Bbbk", "Bmatrix", "Box", "Bumpeq", "Cap", "Cup", "Delta", "Diamond", "Doteq",
      "Downarrow", "Finv", "Game", "Gamma", "Im", "Join", "Lambda", "Leftarrow",
      "Leftrightarrow", "Lleftarrow", "Longleftarrow", "Longleftrightarrow",
      "Longrightarrow", "Lsh", "Omega", "P", "Phi", "Pi", "Pr", "Psi", "Re", "Rightarrow",
      "Rrightarrow", "Rsh", "S", "Sigma", "Subset", "Supset", "Theta", "Uparrow",
      "Updownarrow", "Upsilon", "Vdash", "Vert", "Vmatrix", "Vvdash", "Xi", "acute",
      "aleph", "aligned", "alpha", "amalg", "angle", "approx", "approxeq",
      "arccos", "arcsin", "arctan", "arg", "ast", "asymp", "atop", "attach", "backdprime",
      "backepsilon", "backprime", "backsim", "backsimeq", "backslash", "backtrprime",
      "bar", "barwedge", "because", "beta", "beth", "between", "bigcap", "bigcirc",
      "bigcup", "bigodot", "bigoplus", "bigotimes", "bigsqcup", "bigstar",
      "bigtriangledown", "bigtriangleup", "biguplus", "bigvee", "bigwedge", "binom",
      "blacklozenge", "blacksquare", "blacktriangle", "blacktriangledown",
      "blacktriangleleft", "blacktriangleright", "blockmath", "bmatrix", "bot", "bowtie",
      "boxdot", "boxminus", "boxplus", "boxtimes", "breve", "bullet", "bumpeq", "cap",
      "cases", "cdot", "cdotp", "cdots", "centerdot", "cfrac", "check", "checkmark",
      "chi", "circ", "circeq", "circlearrowleft", "circlearrowright", "circledR",
      "circledS", "circledast", "circledcirc", "circleddash", "clubsuit", "colon",
      "complement", "cong", "coprod", "copyright", "cos", "cosh", "cot", "coth", "csc",
      "csch", "ctg", "cup", "curlyeqprec", "curlyeqsucc", "curlyvee", "curlywedge",
      "curvearrowleft", "curvearrowright", "dag", "dagger", "daleth", "dashleftarrow",
      "dashrightarrow", "dashv", "dbinom", "ddag", "ddagger", "ddddot", "dddot", "ddot",
      "ddots", "deg", "delta", "det", "dfrac", "diagdown", "diagup", "diameter",
      "diamond", "diamondsuit", "digamma", "dim", "div", "divideontimes", "document",
      "dot", "doteq", "doteqdot", "dotplus", "dotsb", "dotsc", "dotsi", "dotsm", "dotso",
      "doublebarwedge", "doublecap", "doublecup", "downarrow", "downdownarrows",
      "downharpoonleft", "downharpoonright", "dprime", "ell", "emph", "emptyset",
      "enspace", "epsilon", "eqcirc", "eqsim", "eqslantgtr", "eqslantless", "equiv",
      "eta", "eth", "exists", "exp", "fallingdotseq", "flat", "forall", "frac", "frown",
      "fullouterjoin", "gamma", "gcd", "ge", "geq", "geqq", "geqslant", "gets", "gg",
      "ggg", "gggtr", "gimel", "gnapprox", "gneq", "gneqq", "gnsim", "grave", "gtrapprox",
      "gtrdot", "gtreqless", "gtreqqless", "gtrless", "gtrsim", "h1", "h2", "h3", "h4",
      "h5", "hat", "hbar", "heartsuit", "hom", "hookleftarrow", "hookrightarrow",
      "hslash", "id", "idotsint", "iff", "iiiint", "iiint", "iint", "im", "imath",
      "impliedby", "implies", "in", "inf", "infty", "injlim", "inlinemath", "int",
      "intercal", "intop", "iota", "jmath", "kappa", "ker", "lVert", "lambda", "land",
      "langle", "lbrace", "lbrack", "lceil", "lcm", "ldotp", "ldots", "le", "leadsto",
      "leftarrow", "leftarrowtail", "leftharpoondown", "leftharpoonup", "leftleftarrows",
      "leftouterjoin", "leftrightarrow", "leftrightarrows", "leftrightharpoons",
      "leftrightsquigarrow", "leftthreetimes", "leq", "leqq", "leqslant", "lessapprox",
      "lessdot", "lesseqgtr", "lesseqqgtr", "lessgtr", "lesssim", "lfloor", "lg",
      "lgroup", "lhd", "lim", "liminf", "limsup", "linebreak", "ll", "llcorner", "lll",
      "llless", "lmoustache", "ln", "lnapprox", "lneq", "lneqq", "lnot", "lnsim", "log",
      "longleftarrow", "longleftrightarrow", "longmapsto", "longrightarrow",
      "looparrowleft", "looparrowright", "lor", "lozenge", "lrcorner", "lrdelim",
      "ltimes", "lvert", "maltese", "mapsto", "mathbb", "mathbf", "mathbin", "mathcal",
      "mathclose", "mathfrak", "mathinner", "mathit", "mathop", "mathopen", "mathord",
      "mathpunct", "mathrel", "mathring", "mathrm", "mathsf", "mathtt", "matrix", "max",
      "measuredangle", "medmuskip", "mho", "mid", "min", "mod", "models", "mp", "mu",
      "multimap", "nLeftarrow", "nLeftrightarrow", "nRightarrow", "nVDash", "nVdash",
      "nabla", "natural", "ncong", "ne", "nearrow", "neg", "neq", "nexists", "ngeq",
      "ngtr", "ni", "nleftarrow", "nleftrightarrow", "nleq", "nless", "nmid", "notin",
      "nparallel", "nprec", "npreceq", "nrightarrow", "nsim", "nsubseteq", "nsucc",
      "nsucceq", "nsupseteq", "ntriangleleft", "ntrianglelefteq", "ntriangleright",
      "ntrianglerighteq", "nu", "nvDash", "nvdash", "nwarrow", "odot", "oiiint", "oiint",
      "oint", "omega", "ominus", "oplus", "oslash", "otimes", "overbar", "overbrace",
      "overbracket", "overleftarrow", "overleftrightarrow", "overline", "overparen",
      "overrightarrow", "ovhook", "owns", "paragraph", "parallel", "partial", "perp",
      "phi", "pi", "pitchfork", "pm", "pmatrix", "pounds", "prec", "precapprox",
      "preccurlyeq", "preceq", "precnapprox", "precneqq", "precnsim", "precsim", "prime",
      "prod", "projlim", "propto", "psi", "qprime", "qquad", "quad", "rVert", "rangle",
      "rbrace", "rbrack", "rceil", "restriction", "rfloor", "rgroup", "rhd", "rho",
      "rightarrow", "rightarrowtail", "rightharpoondown", "rightharpoonup",
      "rightleftarrows", "rightleftharpoons", "rightouterjoin", "rightrightarrows",
      "rightsquigarrow", "rightthreetimes", "risingdotseq", "rmoustache", "rtimes",
      "rvert", "searrow", "sec", "sech", "setminus", "sharp", "sigma", "sim", "simeq",
      "sin", "sinc", "sinh", "smallsetminus", "smile", "spadesuit", "sphericalangle",
      "sqcap", "sqcup", "sqrt", "sqsubset", "sqsubseteq", "sqsupset", "sqsupseteq",
      "square", "star", "strong", "subset", "subseteq", "subseteqq", "subsetneq",
      "subsetneqq", "succ", "succapprox", "succcurlyeq", "succeq", "succnapprox",
      "succneqq", "succnsim", "succsim", "sum", "sup", "supset", "supseteq", "supseteqq",
      "supsetneq", "supsetneqq", "surd", "swarrow", "tan", "tanh", "tau", "tbinom",
      "text", "tfrac", "tg", "therefore", "theta", "thickmuskip", "thinmuskip", "tilde",
      "times", "to", "top", "tr", "triangle", "triangledown", "triangleleft",
      "trianglelefteq", "triangleq", "triangleright", "trianglerighteq", "trprime",
      "twoheadleftarrow", "twoheadrightarrow", "ulcorner", "underbrace", "underbracket",
      "underleftarrow", "underleftrightarrow", "underline", "underparen",
      "underrightarrow", "unlhd", "unrhd", "uparrow", "updownarrow", "upharpoonleft",
      "upharpoonright", "uplus", "upsilon", "upuparrows", "urcorner", "vDash", "varDelta",
      "varepsilon", "varinjlim", "varkappa", "varliminf", "varlimsup", "varnothing",
      "varphi", "varpi", "varprojlim", "varrho", "varsigma", "vartheta", "vartriangle",
      "vartriangleleft", "vartriangleright", "vdash", "vdots", "vec", "vee", "veebar",
      "vert", "vmatrix", "wedge", "widebreve", "widecheck", "widehat", "wideoverbar",
      "widetilde", "wp", "wr", "xi", "yen", "zeta",
    ]

    #expect(tags.count == 594)
    let unexpected = tags.filter { !expected.contains($0) }
    #expect(unexpected.isEmpty, "Unexpected tags: \(unexpected)")
    let missing = expected.filter { !tags.contains($0) }
    #expect(missing.isEmpty, "Missing tags: \(missing)")
    #expect(tags == expected)
  }
}
