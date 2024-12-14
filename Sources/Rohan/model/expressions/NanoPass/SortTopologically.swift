// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation
import SatzAlgorithms

struct SortTopologically: NanoPass {
    typealias Input = [AnnotatedTemplate<TemplateUses>]
    typealias Output = [AnnotatedTemplate<TemplateUses>]

    func process(
        _ templates: [AnnotatedTemplate<TemplateUses>]
    ) -> PassResult<[AnnotatedTemplate<TemplateUses>]> {
        let output = Self.tsort(templates)

        if output.count != templates.count {
            return .failure(PassError())
        }
        return .success(output)
    }

    private static func tsort(
        _ templates: [AnnotatedTemplate<TemplateUses>]
    ) -> [AnnotatedTemplate<TemplateUses>] {
        typealias TSorter = SatzAlgorithms.TSorter<TemplateName>
        typealias Arc = TSorter.Arc

        let sorted = {
            let vertices = Set(templates.map { $0.name })
            let edges = templates.flatMap { template in
                template.annotation.map { use in
                    Arc(use, template.name)
                }
            }
            return TSorter.tsort(vertices, edges)
        }()

        guard let sorted else {
            return []
        }

        let dict = Dictionary(uniqueKeysWithValues: zip(templates.map { $0.name },
                                                        templates.map { $0 }))
        return sorted.map { dict[$0]! }
    }
}
