// Copyright 2024-2025 Lie Yan

import UniformTypeIdentifiers

extension UTType {
  static let latexDocument = UTType(
    exportedAs: "org.latex-project.tex", conformingTo: .plainText)

  static let rohanDocument = UTType(
    exportedAs: "net.satzlich.rohan", conformingTo: .data)
}
