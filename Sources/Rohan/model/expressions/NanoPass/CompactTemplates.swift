// Copyright 2024 Lie Yan

struct CompactTemplates: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    func process(_ input: [Template]) -> PassResult<[Template]> {
        let output = input.map { Self.compactTemplate($0) }
        return .success(output)
    }

    private static func compactTemplate(_ template: Template) -> Template {
        Template(name: template.name,
                 parameters: template.parameters,
                 body: ExpressionUtils.compactContent(template.body))!
    }
}
