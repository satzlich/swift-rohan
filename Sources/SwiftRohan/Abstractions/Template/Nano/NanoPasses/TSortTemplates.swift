// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import HashTreeCollections
import SatzAlgorithms

extension Nano {
  struct TSortTemplates: NanoPass {
    typealias Input = [AnnotatedTemplate<TemplateNames>]
    typealias Output = [AnnotatedTemplate<TemplateNames>]

    static func process(
      _ input: [AnnotatedTemplate<TemplateNames>]
    ) -> PassResult<[AnnotatedTemplate<TemplateNames>]> {
      let output = Self.tsort(input)
      return output.count == input.count
        ? .success(output)
        : .failure(PassError())
    }

    private static func tsort(
      _ templates: [AnnotatedTemplate<TemplateNames>]
    ) -> [AnnotatedTemplate<TemplateNames>] {
      // obtain sorted names
      let sorted: Array<TemplateName>? = {
        let vertices = Set(templates.map(\.name))
        let edges = templates.flatMap { template in
          template.annotation.map { callee in
            Arc(callee, template.name)
          }
        }
        return Satz.tsort(vertices, edges)
      }()
      guard let sorted else { return [] }

      // obtain sorted templates
      let dict = Dictionary(uniqueKeysWithValues: zip(templates.map(\.name), templates))
      return sorted.map { dict[$0]! }
    }
  }
}
