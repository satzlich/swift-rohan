// Copyright 2024 Lie Yan

enum TemplateUtils {
    /**
     Returns true if the template is free of apply (named only)

     - Complexity: O(n)
     */
    static func isApplyFree(_ template: Template) -> Bool {
        Espresso.plugAndPlay(Espresso.counter(predicate: { $0.isApply }),
                             template.body)
            .count == 0
    }
}
