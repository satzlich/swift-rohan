// Copyright 2024 Lie Yan

import Foundation

struct TemplateUtils {
    static func dictionaryOfTemplates(_ templates: [Template]) -> [Identifier: Template] {
        templates.reduce(into: [Identifier: Template]()) { dict, template in
            dict[template.name] = template
        }
    }
}
