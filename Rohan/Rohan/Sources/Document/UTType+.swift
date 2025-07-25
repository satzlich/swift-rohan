import SwiftRohan
import UniformTypeIdentifiers

extension UTType {
  static let latexDocument = UTType(
    exportedAs: "org.latex-project.tex", conformingTo: .plainText)

  static let rohanDocument = UTType(
    exportedAs: "net.satzlich.rohan", conformingTo: .data)
}

extension DocumentContent.OutputFormat {
  func toUTType() -> UTType {
    switch self {
    case .latex: return .latexDocument
    case .rohan: return .rohanDocument
    }
  }

  static func fromUTType(_ typeName: String) -> DocumentContent.OutputFormat? {
    switch typeName {
    case UTType.latexDocument.identifier: return .latex
    case UTType.rohanDocument.identifier: return .rohan
    default: return nil
    }
  }
}
