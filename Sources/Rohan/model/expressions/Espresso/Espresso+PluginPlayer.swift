// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Convenience function to apply a plugin
     */
    static func applyPlugin<P>(_ plugin: P, _ content: Content) -> P
    where P: VisitorPlugin, P.Context == Void {
        let player = PluginPlayer(plugin)
        player.visitContent(content, ())
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
