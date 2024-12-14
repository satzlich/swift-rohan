// Copyright 2024 Lie Yan

enum TemplateUtils {
    /**
     Returns true if the template is free of apply (named only)

     - Complexity: O(n)
     */
    static func isApplyFree(_ template: Template) -> Bool {
        let counter = Espresso.PredicatedCounter(Espresso.isApply)
        return Espresso.applyPlugin(counter, template.body).count == 0
    }


}
