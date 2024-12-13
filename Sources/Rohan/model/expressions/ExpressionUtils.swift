// Copyright 2024 Lie Yan

import Foundation

enum ExpressionUtils {
    static func applyPlugins(_ plugins: [ExpressionVisitorPlugin<Void>],
                             _ content: Content)
    {
        ExpressionPluginVisitor(plugins).invoke(with: content)
    }
}
