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
      "Angstrom", "Bmatrix", "Bumpeq", "Cap", "Colon", "Cup", "DDownarrow",
      "Ddownarrow", "Delta", "Diamond", "Digamma", "Doteq", "Downarrow", "Eulerconst",
      "Finv", "Game", "Gamma", "Im", "Join", "Lambda", "Lbrbrak", "Leftarrow",
      "Leftrightarrow", "Lleftarrow", "Longleftarrow", "Longleftrightarrow",
      "Longmapsfrom", "Longmapsto", "Longrightarrow", "Lsh", "Mapsfrom", "Mapsto",
      "Omega", "Phi", "Pi", "Planckconst", "Pr", "Psi", "QED", "Rbrbrak", "Re",
      "Rightarrow", "Rrightarrow", "Rsh", "Sigma", "Subset", "Supset", "Theta",
      "UUparrow", "Uparrow", "Updownarrow", "Upsilon", "Uuparrow", "Vdash", "Vert",
      "Vmatrix", "Vvdash", "Xi", "acute", "acwgapcirclearrow", "acwleftarcarrow",
      "acwoverarcarrow", "acwunderarcarrow", "adots", "aleph", "aligned", "alpha",
      "amalg", "angle", "approx", "approxeq", "arccos", "arcsin", "arctan", "arg",
      "ast", "asymp", "atop", "attach", "awint", "backdprime", "backepsilon",
      "backprime", "backsim", "backsimeq", "backslash", "backtrprime", "bar",
      "barrightarrowdiamond", "baruparrow", "barwedge", "because", "beta", "beth",
      "between", "bigbot", "bigcap", "bigcirc", "bigcup", "bigcupdot", "bigodot",
      "bigoplus", "bigotimes", "bigsqcap", "bigsqcup", "bigstar", "bigtimes", "bigtop",
      "bigtriangledown", "bigtriangleup", "biguplus", "bigvee", "bigwedge", "binom",
      "blacklozenge", "blacksquare", "blacktriangle", "blacktriangledown",
      "blacktriangleleft", "blacktriangleright", "blockmath", "bmatrix", "bot",
      "bowtie", "boxdot", "boxminus", "boxplus", "boxtimes", "breve", "bullet",
      "bumpeq", "cap", "cases", "cdot", "cdotp", "cdots", "centerdot", "check",
      "checkmark",
      "chi", "circ", "circeq", "circlearrowleft", "circlearrowright", "circledR",
      "circledS", "circledast", "circledcirc", "circleddash", "cirfnint", "clubsuit",
      "colon", "complement", "cong", "conjquant", "coprod", "cos", "cosh", "cot", "coth",
      "csc", "csch", "ctg", "cup", "curlyeqprec", "curlyeqsucc", "curlyvee", "curlywedge",
      "curvearrowleft", "curvearrowleftplus", "curvearrowright", "curvearrowrightminus",
      "cwgapcirclearrow", "cwrightarcarrow", "dagger", "daleth", "dashleftarrow",
      "dashrightarrow", "dashv", "dbinom", "dbkarrow", "ddagger", "ddddot", "dddot",
      "ddot", "ddots", "deg", "delta",
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
      "grave", "gtrapprox", "gtrdot", "gtreqless", "gtreqqless", "gtrless", "gtrsim",
      "h1", "h2", "h3", "h4", "h5", "hat", "hbar", "heartsuit", "hknearrow",
      "hknwarrow", "hksearrow", "hkswarrow", "hom", "hookleftarrow", "hookrightarrow",
      "hslash", "id", "iiiint", "iiint", "iint", "im", "imath", "in", "increment",
      "inf", "infty", "inlinemath", "int", "intBar", "intbar", "intcap", "intclockwise",
      "intcup", "intercal", "intlarhk", "intx", "iota", "isinE", "isindot", "isinobar",
      "isins", "isinvb", "jmath", "kappa", "ker", "lAngle", "lBrack", "lambda", "land",
      "langle", "lbrbrak", "lceil", "lcm", "ldots", "le", "leadsto", "leftarrow",
      "leftarrowtail", "leftbkarrow", "leftdbkarrow", "leftdbltail",
      "leftdowncurvedarrow", "leftharpoondown", "leftharpoonup", "leftleftarrows",
      "leftouterjoin", "leftrightarrow", "leftrightarrows", "leftrightharpoons",
      "leftrightsquigarrow", "leftsquigarrow", "lefttail", "leftthreetimes", "leq",
      "leqq", "leqslant", "lessapprox", "lessdot", "lesseqgtr", "lesseqqgtr", "lessgtr",
      "lesssim", "lfloor", "lg", "lgroup", "lhd", "lim", "liminf", "limsup",
      "linebreak", "ll", "llcorner", "lll", "llless", "lmoustache", "ln", "lnapprox",
      "lneq", "lneqq", "lnot", "lnsim", "log", "longleftarrow", "longleftrightarrow",
      "longmapsfrom", "longmapsto", "longrightarrow", "longrightsquigarrow",
      "looparrowleft", "looparrowright", "lor", "lowint", "lozenge", "lrcorner",
      "lrdelim", "ltimes", "maltese", "mapsfrom", "mapsto", "mathbb", "mathbf", "mathbin",
      "mathcal", "mathclose", "mathfrak", "mathinner", "mathit", "mathop", "mathopen",
      "mathord", "mathpunct", "mathrel", "mathring", "mathrm", "mathsf", "mathtt",
      "matrix", "max", "measuredangle", "measuredrightangle", "medmuskip", "mho", "mid",
      "min", "mod", "models", "modtwosum", "mp", "mu", "multimap", "nLeftarrow",
      "nLeftrightarrow", "nRightarrow", "nVDash", "nVdash", "nVrightarrowtail",
      "nVtwoheadrightarrow", "nVtwoheadrightarrowtail", "nabla", "natural", "ncong",
      "ne", "nearrow", "neg", "neovnwarrow", "neovsearrow", "neq", "nequiv",
      "neswarrow", "nexists", "ngeq", "ngtr", "ni", "niobar", "nis", "nisd",
      "nleftarrow", "nleftrightarrow", "nleq", "nless", "nmid", "nni", "notin",
      "nparallel", "npolint", "nprec", "npreceq", "nrightarrow", "nsim", "nsubset",
      "nsubseteq", "nsucc", "nsucceq", "nsupset", "nsupseteq", "ntriangleleft",
      "ntrianglelefteq",
      "ntriangleright", "ntrianglerighteq", "nu", "nvDash", "nvLeftarrow",
      "nvLeftrightarrow", "nvRightarrow", "nvdash", "nvrightarrowtail",
      "nvtwoheadrightarrow", "nvtwoheadrightarrowtail", "nwarrow", "nwovnearrow",
      "nwsearrow", "odot", "oiiint", "oiint", "oint", "ointctrclockwise", "omega",
      "ominus", "oplus", "oslash", "otimes", "overbar", "overbrace", "overbracket",
      "overleftarrow", "overleftrightarrow", "overline", "overparen", "overrightarrow",
      "ovhook", "paragraph", "parallel", "partial", "perp",
      "phi", "pi", "pitchfork", "pm", "pmatrix", "pointint", "prec", "precapprox",
      "preccurlyeq", "preceq", "precnapprox", "precneqq", "precnsim", "precsim",
      "prime", "prod", "propto", "psi", "qprime", "qquad", "quad", "rAngle", "rBrack",
      "rangle",
      "rangledownzigzagarrow", "rbrbrak", "rceil", "rdiagovfdiag", "rdiagovsearrow",
      "restriction", "rfloor", "rgroup", "rhd", "rho", "rightangle", "rightarrow",
      "rightarrowdiamond", "rightarrowonoplus", "rightarrowtail", "rightbkarrow",
      "rightcurvedarrow", "rightdbltail", "rightdotarrow", "rightdowncurvedarrow",
      "rightharpoondown", "rightharpoonup", "rightleftarrows", "rightleftharpoons",
      "rightouterjoin", "rightrightarrows", "rightsquigarrow", "righttail",
      "rightthreetimes", "risingdotseq", "rmoustache", "rppolint", "rtimes", "scpolint",
      "searrow", "sec", "sech", "seovnearrow", "setminus", "sharp", "sigma", "sim",
      "simeq", "sin", "sinc", "sinh", "smalltriangledown",
      "smalltriangleup", "smile", "spadesuit", "sphericalangle", "sqcap", "sqcup",
      "sqint", "sqrt", "sqsubset", "sqsubseteq", "sqsupset", "sqsupseteq", "square",
      "star", "strong", "subset", "subsetcirc", "subseteq", "subseteqq", "subsetneq",
      "subsetneqq", "succ", "succapprox", "succcurlyeq", "succeq", "succnapprox",
      "succneqq", "succnsim", "succsim", "sum", "sumint", "sup", "supset", "supsetcirc",
      "supseteq", "supseteqq", "supsetneq", "supsetneqq", "surd", "swarrow", "tan",
      "tanh", "tau", "tbinom", "text", "tfrac", "tg", "therefore", "theta", "thickmuskip",
      "thinmuskip", "tilde", "times",
      "to", "toea", "tona", "top", "tosa", "towa", "tr", "triangleleft",
      "trianglelefteq", "triangleq", "triangleright", "trianglerighteq", "trprime",
      "twoheadleftarrow", "twoheadmapsto", "twoheadrightarrow", "twoheadrightarrowtail",
      "ulcorner", "underbrace", "underbracket", "underleftarrow", "underleftrightarrow",
      "underline", "underparen", "underrightarrow", "uparrow",
      "uparrowbarred", "updownarrow", "updownarrows", "upharpoonleft", "upharpoonright",
      "upint", "uplus", "uprightcurvearrow", "upsilon", "upuparrows", "urcorner",
      "vDash", "varclubsuit", "vardiamondsuit", "varepsilon", "varheartsuit",
      "varisinobar", "varisins", "varkappa", "varniobar", "varnis", "varnothing",
      "varointclockwise", "varphi", "varpi", "varrho", "varsigma", "varspadesuit",
      "vartheta", "vartriangleleft", "vartriangleright", "vdash", "vdots", "vec", "vee",
      "veebar", "vert", "visiblespace", "vmatrix", "wedge", "widebreve", "widecheck",
      "widehat", "wideoverbar", "widetilde", "wp", "wr", "xi", "yen", "zeta",
    ]
    #expect(tags.count == 701)
    let diff = tags.filter { !expected.contains($0) }
    #expect(diff.isEmpty, "Unexpected tags: \(diff)")
    #expect(tags == expected)
  }
}
