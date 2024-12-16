// Copyright 2024 Lie Yan

import Foundation

extension Nano {
    struct CheckDanglingTemplateCalls: NanoPass {
        typealias Input = [AnnotatedTemplate<TemplateCalls>]
        typealias Output = [AnnotatedTemplate<TemplateCalls>]

        static func process(
            _ input: [AnnotatedTemplate<TemplateCalls>]
        ) -> PassResult<[AnnotatedTemplate<TemplateCalls>]> {
            let templates = Set(input.map { $0.canonical.name })

            let okay = input.allSatisfy { template in
                template.annotation.allSatisfy { callee in
                    templates.contains(callee)
                }
            }

            if okay {
                return .success(input)
            }
            else {
                return .failure(PassError())
            }
        }
    }
}
