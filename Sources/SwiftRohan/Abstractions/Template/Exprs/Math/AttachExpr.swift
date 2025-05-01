// Copyright 2024-2025 Lie Yan

final class AttachExpr: MathExpr {
  class override var type: ExprType { .attach }

  let lsub: ContentExpr?
  let lsup: ContentExpr?
  let nucleus: ContentExpr
  let sub: ContentExpr?
  let sup: ContentExpr?

  init(
    nuc: [Expr], lsub: [Expr]? = nil, lsup: [Expr]? = nil,
    sub: [Expr]? = nil, sup: [Expr]? = nil
  ) {
    self.lsub = lsub.map(ContentExpr.init)
    self.lsup = lsup.map(ContentExpr.init)
    self.nucleus = ContentExpr(nuc)
    self.sub = sub.map(ContentExpr.init)
    self.sup = sup.map(ContentExpr.init)
    super.init()
  }

  init(
    nuc: ContentExpr, lsub: ContentExpr? = nil, lsup: ContentExpr? = nil,
    sub: ContentExpr? = nil, sup: ContentExpr? = nil
  ) {
    self.lsub = lsub
    self.lsup = lsup
    self.nucleus = nuc
    self.sub = sub
    self.sup = sup
    super.init()
  }

  func with(lsub: ContentExpr?) -> AttachExpr {
    AttachExpr(nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  func with(lsup: ContentExpr?) -> AttachExpr {
    AttachExpr(nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  func with(nucleus: ContentExpr) -> AttachExpr {
    AttachExpr(nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  func with(sub: ContentExpr?) -> AttachExpr {
    AttachExpr(nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  func with(sup: ContentExpr?) -> AttachExpr {
    AttachExpr(nuc: nucleus, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(attach: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    var components: [MathExpr.MathComponent] = []
    if let lsub = lsub { components.append((.lsub, lsub)) }
    if let lsup = lsup { components.append((.lsup, lsup)) }
    components.append((.nuc, nucleus))
    if let sub = sub { components.append((.sub, sub)) }
    if let sup = sup { components.append((.sup, sup)) }
    return components
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case lsub, lsup, sub, sup, nuc }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    lsub = try container.decodeIfPresent(ContentExpr.self, forKey: .lsub)
    lsup = try container.decodeIfPresent(ContentExpr.self, forKey: .lsup)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    sub = try container.decodeIfPresent(ContentExpr.self, forKey: .sub)
    sup = try container.decodeIfPresent(ContentExpr.self, forKey: .sup)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(lsub, forKey: .lsub)
    try container.encodeIfPresent(lsup, forKey: .lsup)
    try container.encode(nucleus, forKey: .nuc)
    try container.encodeIfPresent(sub, forKey: .sub)
    try container.encodeIfPresent(sup, forKey: .sup)
    try super.encode(to: encoder)
  }
}
