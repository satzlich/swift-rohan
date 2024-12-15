// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation
import SatzAlgorithms

extension Nano {
    struct SortTopologically: NanoPass {
        typealias Input = [AnnotatedTemplate<TemplateCalls>]
        typealias Output = [AnnotatedTemplate<TemplateCalls>]

        func process(
            input: [AnnotatedTemplate<TemplateCalls>]
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
}
