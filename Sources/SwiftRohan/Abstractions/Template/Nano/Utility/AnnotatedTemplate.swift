// Copyright 2024-2025 Lie Yan

extension Nano {
  /// A template with annotation
  struct AnnotatedTemplate<A> {
    typealias Annotation = A

    let template: Template
    let annotation: A

    var name: TemplateName { template.name }
    var parameters: Array<Identifier> { template.parameters }
    var body: Array<Expr> { template.body }

    init(_ template: Template, annotation: A) {
      self.template = template
      self.annotation = annotation
    }
  }
}
