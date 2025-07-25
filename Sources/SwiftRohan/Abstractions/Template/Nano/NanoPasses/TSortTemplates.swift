import Algorithms
import Foundation
import HashTreeCollections
import SatzAlgorithms

extension Nano {
  struct TSortTemplates: NanoPass {
    typealias Input = Array<AnnotatedTemplate<TemplateNames>>
    typealias Output = Array<AnnotatedTemplate<TemplateNames>>

    static func process(
      _ input: Array<AnnotatedTemplate<TemplateNames>>
    ) -> PassResult<Array<AnnotatedTemplate<TemplateNames>>> {
      let output = Self.tsort(input)
      return output.count == input.count
        ? .success(output)
        : .failure(PassError())
    }

    private static func tsort(
      _ templates: Array<AnnotatedTemplate<TemplateNames>>
    ) -> Array<AnnotatedTemplate<TemplateNames>> {
      // obtain sorted names
      let sorted: Array<TemplateName>?
      do {
        let vertices = Set(templates.map(\.name))
        let edges = templates.flatMap { template in
          template.annotation.map { callee in
            Arc(callee, template.name)
          }
        }
        sorted = Satz.tsort(vertices, edges)
      }
      guard let sorted else { return [] }

      // obtain sorted templates
      let dict = Dictionary(uniqueKeysWithValues: zip(templates.map(\.name), templates))
      return sorted.map { dict[$0]! }
    }
  }
}
