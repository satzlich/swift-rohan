// Copyright 2024 Lie Yan

import Foundation

/**

 - Note: In TeX, we have commands like `\mathbb`, `\mathcal`, `\mathfrak`.

 */
public enum MathVariant: Equatable, Hashable, Codable {
    /// Serif (default variant)
    case serif
    /// Sans serif
    case sans
    /// Fraktur
    case frak
    /// Monospace
    case mono
    /// Blackboard
    case bb
    /// Calligraphy
    case cal
}
