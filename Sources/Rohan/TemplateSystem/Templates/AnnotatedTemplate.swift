// Copyright 2024-2025 Lie Yan

extension Nano {
  /** A template with an annotation */
  struct AnnotatedTemplate<A> {
    typealias Annotation = A

    let canonical: Template
    let annotation: A

    var name: TemplateName { canonical.name }
    var parameters: [Identifier] { canonical.parameters }
    var body: [RhExpr] { canonical.body }

    init(_ canonical: Template, annotation: A) {
      self.canonical = canonical
      self.annotation = annotation
    }
  }
}
