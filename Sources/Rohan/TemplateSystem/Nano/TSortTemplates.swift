// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import HashTreeCollections
import SatzAlgorithms

extension Nano {
  struct TSortTemplates: NanoPass {
    typealias Input = [AnnotatedTemplate<TemplateCalls>]
    typealias Output = [AnnotatedTemplate<TemplateCalls>]

    static func process(
      _ input: [AnnotatedTemplate<TemplateCalls>]
    ) -> PassResult<[AnnotatedTemplate<TemplateCalls>]> {
      let output = Self.tsort(input)

      if output.count != input.count {
        return .failure(PassError())
      }
      return .success(output)
    }

    private static func tsort(
      _ templates: [AnnotatedTemplate<TemplateCalls>]
    ) -> [AnnotatedTemplate<TemplateCalls>] {
      let sorted = {
        let vertices = Set(templates.map(\.name))
        let edges = templates.flatMap { template in
          template.annotation.map { callee in
            Arc(callee, template.name)
          }
        }
        return Satz.tsort(vertices, edges)
      }()

      guard let sorted else { return [] }

      let dict = Dictionary(uniqueKeysWithValues: zip(templates.map(\.name), templates))
      return sorted.map { dict[$0]! }
    }
  }
}
