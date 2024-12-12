// Copyright 2024 Lie Yan

struct TemplateName: Equatable, Hashable {
    let identifier: Identifier

    init(_ identifier: Identifier) {
        self.identifier = identifier
    }

    init?(_ string: String) {
        guard let identifier = Identifier(string) else {
            return nil
        }
        self.init(identifier)
    }
}
