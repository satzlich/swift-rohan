// Copyright 2024 Lie Yan

extension Nano {
    struct ConvertToNameless: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(input: [Template]) -> PassResult<[Template]> {
            let output = input.map(Self.eliminateNames)
            return .success(output)
        }

        private static func eliminateNames(_ template: Template) -> Template {
            preconditionFailure()
        }
    }
}
