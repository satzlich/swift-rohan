// Copyright 2024 Lie Yan

import Foundation

enum alonzo {
    final class Function {
        /*
         parameters, which are name and type pairs
         body, which is an expression
         */
    }

    protocol Expression {
    }

    final class Constant: Expression {
    }

    final class Variable: Expression {
    }

    final class Apply: Expression {
        /*
         reference to function,
         arguments
         */
    }

    /**
     concatenation
     */
    final class Content: Expression {
    }
}
