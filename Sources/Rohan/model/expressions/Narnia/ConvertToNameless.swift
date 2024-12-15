// Copyright 2024 Lie Yan

extension Narnia {
    struct ConvertToNameless: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map(Self.eliminateNames)
            return .success(output)
        }

        static func eliminateNames(_ template: Template) -> Template {
            preconditionFailure()
        }
    }
}
