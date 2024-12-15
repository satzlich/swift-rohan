// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Convenience function to simply play a plugin on a content
     */
    static func plugAndPlay<P>(_ plugin: P, _ content: Content) -> P
        where P: VisitorPlugin, P.Context == Void
    {
        let player = PluginPlayer(plugin)
        player.visit(content: content, ())
        return player.plugin
    }

    final class PluginPlayer<P>: ExpressionVisitor<P.Context> where P: VisitorPlugin {
        typealias Context = P.Context

        private(set) var plugin: P

        init(_ plugin: P) {
            self.plugin = plugin
        }

        override func visitExpression(_ expression: Expression, _ context: Context) {
            plugin.visitExpression(expression, context)
            super.visitExpression(expression, context)
        }
    }
}
