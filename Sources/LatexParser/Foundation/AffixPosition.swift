/// The affix position of command.
/// ## Example
/// ```
/// $\frac{a}{b}$ % prefix
/// $a\atop b$ % infix
///
/// % `\sum` inapplicable, `\nolimits` postfix
/// $\sum\nolimits_{i=1}^{n} a_i$
/// ```
public enum AffixPosition: String, Codable, Sendable {
  case prefix
  case infix
  case postfix
  case undefined
}
