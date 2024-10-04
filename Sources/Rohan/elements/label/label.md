# Label mechanism specification

**Interaction**. A `reference` is an intention to refer to a particular `element` 
that is attached to by a `label` through a `text` for `Label`.

- Label
  - intrinsic
    - text: String (subject to syntax check)
  - contextual
    - attachedTo: any Object?

- Reference
  - semantic
    - An intention to reference a single labelled object
  - intrinsic
    - text: String
  - contextual
    - label: Label?
