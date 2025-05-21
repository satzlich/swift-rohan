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
      "And", "Angstrom", "Bmatrix", "Box", "Bumpeq", "Cap", "Colon", "Cup", "DDownarrow",
      "Ddownarrow", "Delta", "Diamond", "Digamma", "Doteq", "Downarrow", "Eulerconst",
      "Finv", "Game", "Gamma", "Im", "Join", "Lambda", "Lbrbrak", "Leftarrow",
      "Leftrightarrow", "Lleftarrow", "Longleftarrow", "Longleftrightarrow",
      "Longmapsfrom", "Longmapsto", "Longrightarrow", "Lsh", "Mapsfrom", "Mapsto",
      "Omega", "P", "Phi", "Pi", "Planckconst", "Pr", "Psi", "QED", "Rbrbrak", "Re",
      "Rightarrow", "Rrightarrow", "Rsh", "S", "Sigma", "Subset", "Supset", "Theta",
      "UUparrow", "Uparrow", "Updownarrow", "Upsilon", "Uuparrow", "Vdash", "Vert",
      "Vmatrix", "Vvdash", "Xi", "acute", "acwgapcirclearrow", "acwleftarcarrow",
      "acwoverarcarrow", "acwunderarcarrow", "adots", "aleph", "aligned", "alpha",
      "amalg", "angle", "approx", "approxeq", "arccos", "arcsin", "arctan", "arg",
      "ast", "asymp", "atop", "attach", "awint", "backdprime", "backepsilon",
      "backprime", "backsim", "backsimeq", "backslash", "backtrprime", "bar",
      "barrightarrowdiamond", "baruparrow", "barwedge", "because", "beta", "beth",
      "between", "bigblacktriangledown", "bigbot", "bigcap", "bigcirc", "bigcup",
      "bigcupdot", "bigodot",
      "bigoplus", "bigotimes", "bigsqcap", "bigsqcup", "bigstar", "bigtimes", "bigtop",
      "bigtriangledown", "bigtriangleup", "biguplus", "bigvee", "bigwedge", "binom",
      "blacklozenge", "blacksquare", "blacktriangle", "blacktriangledown",
      "blacktriangleleft", "blacktriangleright", "blockmath", "bmatrix", "bot",
      "bowtie", "boxdot", "boxminus", "boxplus", "boxtimes", "breve", "bullet",
      "bumpeq", "cap", "cases", "cdot", "cdotp", "cdots", "centerdot", "cfrac", "check",
      "checkmark",
      "chi", "circ", "circeq", "circlearrowleft", "circlearrowright", "circledR",
      "circledS", "circledast", "circledcirc", "circleddash", "cirfnint", "clubsuit",
      "colon", "complement", "cong", "conjquant", "coprod", "cos", "cosh", "cot", "coth",
      "csc", "csch", "ctg", "cup", "curlyeqprec", "curlyeqsucc", "curlyvee", "curlywedge",
      "curvearrowleft", "curvearrowleftplus", "curvearrowright", "curvearrowrightminus",
      "cwgapcirclearrow", "cwrightarcarrow", "dag", "dagger", "daleth", "dashleftarrow",
      "dashrightarrow", "dashv", "dbinom", "dbkarrow", "ddag", "ddagger", "ddddot",
      "dddot", "ddot", "ddots", "deg", "delta",
      "det", "dfrac", "diagdown", "diagup", "diameter", "diamond", "diamondleftarrow",
      "diamondleftarrowbar", "diamondsuit", "digamma", "dim", "disin", "disjquant",
      "div", "divideontimes", "document", "dot", "doteq", "doteqdot", "dotminus",
      "dotplus", "doublebarwedge", "doublecap", "doublecup", "downarrow",
      "downarrowbar", "downarrowbarred", "downdownarrows", "downharpoonleft",
      "downharpoonright", "downrightcurvedarrow", "dprime", "draftingarrow",
      "drbkarrow", "ell", "emph", "emptyset", "enspace", "epsilon", "eqcirc", "eqsim",
      "eqslantgtr", "eqslantless", "equiv", "eta", "eth", "exists", "exp",
      "fallingdotseq", "fdiagovnearrow", "fdiagovrdiag", "fint", "flat", "forall",
      "frac", "frown", "fullouterjoin", "gamma", "gcd", "ge", "geq", "geqq", "geqslant",
      "gets", "gg", "ggg", "gggtr", "gimel", "gnapprox", "gneq", "gneqq", "gnsim",
      "grave", "gt", "gtrapprox", "gtrdot", "gtreqless", "gtreqqless", "gtrless",
      "gtrsim", "h1", "h2", "h3", "h4", "h5", "hat", "hbar", "heartsuit", "hknearrow",
      "hknwarrow", "hksearrow", "hkswarrow", "hom", "hookleftarrow", "hookrightarrow",
      "hslash", "id", "iff", "iiiint", "iiint", "iint", "im", "imageof", "imath",
      "impliedby", "implies", "in", "increment",
      "inf", "infty", "inlinemath", "int", "intBar", "intbar", "intcap", "intclockwise",
      "intcup", "intercal", "intlarhk", "intop", "intx", "iota", "isinE", "isindot",
      "isinobar",
      "isins", "isinvb", "jmath", "kappa", "ker", "lAngle", "lBrack", "lVert", "lambda",
      "land", "langle", "lbrace", "lbrack", "lbrbrak", "lceil", "lcm", "ldotp", "ldots",
      "le", "leadsto",
      "leftarrow", "leftarrowtail", "leftbkarrow", "leftdbkarrow", "leftdbltail",
      "leftdowncurvedarrow", "leftharpoondown", "leftharpoonup", "leftleftarrows",
      "leftouterjoin", "leftrightarrow", "leftrightarrows", "leftrightharpoons",
      "leftrightsquigarrow", "leftsquigarrow", "lefttail", "leftthreetimes", "leq",
      "leqq", "leqslant", "lessapprox", "lessdot", "lesseqgtr", "lesseqqgtr", "lessgtr",
      "lesssim", "lfloor", "lg", "lgroup", "lhd", "lim", "liminf", "limsup",
      "linebreak", "ll", "llcorner", "lll", "llless", "lmoustache", "ln", "lnapprox",
      "lneq", "lneqq", "lnot", "lnsim", "log", "longleftarrow", "longleftrightarrow",
      "longmapsfrom", "longmapsto", "longrightarrow", "longrightsquigarrow",
      "looparrowleft", "looparrowright", "lor", "lowint", "lozenge", "lparen", "lrcorner",
      "lrdelim", "lt", "ltimes", "lvert", "maltese", "mapsfrom", "mapsto", "mathbb",
      "mathbf", "mathbin", "mathcal", "mathclose", "mathellipsis", "mathfrak",
      "mathinner", "mathit", "mathop", "mathopen", "mathord", "mathpunct", "mathrel",
      "mathring", "mathrm", "mathsf", "mathsterling", "mathtt",
      "matrix", "max", "measuredangle", "measuredrightangle", "medmuskip", "mho", "mid",
      "min", "mod", "models", "modtwosum", "mp", "mu", "multimap", "nLeftarrow",
      "nLeftrightarrow", "nRightarrow", "nVDash", "nVdash", "nVrightarrowtail",
      "nVtwoheadrightarrow", "nVtwoheadrightarrowtail", "nabla", "natural", "ncong",
      "ne", "nearrow", "neg", "neovnwarrow", "neovsearrow", "neq", "nequiv",
      "neswarrow", "nexists", "ngeq", "ngtr", "ni", "niobar", "nis", "nisd",
      "nleftarrow", "nleftrightarrow", "nleq", "nleqq", "nleqslant", "nless", "nmid",
      "nni", "notin", "nparallel", "npolint", "nprec", "npreceq", "nrightarrow",
      "nsim", "nsubset", "nsubseteq", "nsucc", "nsucceq", "nsupset", "nsupseteq",
      "ntriangleleft", "ntrianglelefteq",
      "ntriangleright", "ntrianglerighteq", "nu", "nvDash", "nvLeftarrow",
      "nvLeftrightarrow", "nvRightarrow", "nvdash", "nvrightarrowtail",
      "nvtwoheadrightarrow", "nvtwoheadrightarrowtail", "nwarrow", "nwovnearrow",
      "nwsearrow", "odot", "oiiint", "oiint", "oint", "ointctrclockwise", "omega",
      "omicron", "ominus", "oplus", "origof", "oslash", "otimes", "overbar", "overbrace",
      "overbracket",
      "overleftarrow", "overleftrightarrow", "overline", "overparen", "overrightarrow",
      "ovhook", "owns", "paragraph", "parallel", "partial", "perp", "phi", "pi",
      "pitchfork", "pm", "pmatrix", "pointint", "pounds", "prec", "precapprox",
      "preccurlyeq", "preceq", "precnapprox", "precneqq", "precnsim", "precsim",
      "prime", "prod", "propto", "psi", "qprime", "qquad", "quad", "rAngle", "rBrack",
      "rVert", "rangle", "rangledownzigzagarrow", "rbrace", "rbrack", "rbrbrak", "rceil",
      "rdiagovfdiag", "rdiagovsearrow",
      "restriction", "rfloor", "rgroup", "rhd", "rho", "rightangle", "rightarrow",
      "rightarrowdiamond", "rightarrowonoplus", "rightarrowtail", "rightbkarrow",
      "rightcurvedarrow", "rightdbltail", "rightdotarrow", "rightdowncurvedarrow",
      "rightharpoondown", "rightharpoonup", "rightleftarrows", "rightleftharpoons",
      "rightouterjoin", "rightrightarrows", "rightsquigarrow", "righttail",
      "rightthreetimes", "risingdotseq", "rmoustache", "rparen", "rppolint", "rtimes",
      "rvert", "scpolint",
      "searrow", "sec", "sech", "seovnearrow", "setminus", "sharp", "sigma", "sim",
      "simeq", "sin", "sinc", "sinh", "smallfrown", "smallsmile", "smalltriangledown",
      "smalltriangleup", "smile", "space", "spadesuit", "sphericalangle", "sqcap",
      "sqcup",
      "sqint", "sqrt", "sqsubset", "sqsubseteq", "sqsupset", "sqsupseteq", "square",
      "star", "strong", "subset", "subsetcirc", "subseteq", "subseteqq", "subsetneq",
      "subsetneqq", "succ", "succapprox", "succcurlyeq", "succeq", "succnapprox",
      "succneqq", "succnsim", "succsim", "sum", "sumint", "sup", "supset", "supsetcirc",
      "supseteq", "supseteqq", "supsetneq", "supsetneqq", "surd", "swarrow", "tan",
      "tanh", "tau", "tbinom", "text", "tfrac", "tg", "therefore", "theta", "thickmuskip",
      "thinmuskip", "tilde", "times", "to", "toea", "tona", "top", "tosa",
      "towa", "tr", "triangle", "triangledown", "triangleleft",
      "trianglelefteq", "triangleq", "triangleright", "trianglerighteq", "trprime",
      "twoheadleftarrow", "twoheadmapsto", "twoheadrightarrow", "twoheadrightarrowtail",
      "ulcorner", "underbrace", "underbracket", "underleftarrow", "underleftrightarrow",
      "underline", "underparen", "underrightarrow", "unlhd", "unrhd", "uparrow",
      "uparrowbarred", "updownarrow", "updownarrows", "upharpoonleft", "upharpoonright",
      "upint", "uplus", "uprightcurvearrow", "upsilon", "upuparrows", "urcorner",
      "vDash", "varDelta", "varclubsuit", "vardiamondsuit", "varepsilon", "varheartsuit",
      "varisinobar", "varisins", "varkappa", "varniobar", "varnis", "varnothing",
      "varointclockwise", "varphi", "varpi", "varrho", "varsigma", "varspadesuit",
      "vartheta", "vartriangle", "vartriangleleft", "vartriangleright", "vdash", "vdots",
      "vec", "vee",
      "veebar", "vert", "visiblespace", "vmatrix", "wedge", "widebreve", "widecheck",
      "widehat", "wideoverbar", "widetilde", "wp", "wr", "xi", "yen", "zeta",
    ]
    #expect(tags.count == 744)
    let unexpected = tags.filter { !expected.contains($0) }
    #expect(unexpected.isEmpty, "Unexpected tags: \(unexpected)")
    let missing = expected.filter { !tags.contains($0) }
    #expect(missing.isEmpty, "Missing tags: \(missing)")
    #expect(tags == expected)
  }
}
