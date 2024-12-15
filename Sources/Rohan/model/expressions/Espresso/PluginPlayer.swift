// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Convenience function to simply play a plugin on a content
     */
    static func play<P>(plugin: P, on content: Content) -> P
        where P: VisitorPlugin, P.Context == Void
    {
        let player = PluginPlayer(plugin)
        player.visit(content: content, ())
        return player.plugin
    }

    private final class PluginPlayer<P>: ExpressionVisitor<P.Context> where P: VisitorPlugin {
        typealias Context = P.Context

        private(set) var plugin: P

        init(_ plugin: P) {
            self.plugin = plugin
        }

        override func visit(expression: Expression, _ context: Context) {
            plugin.visit(expression: expression, context)
            super.visit(expression: expression, context)
        }
    }
}
