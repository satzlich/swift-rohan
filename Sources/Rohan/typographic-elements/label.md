# Label mechanism specification

**Interaction**. A `reference` is a mention of a particular `element` 
that is attached to by a `label` through a `name` for `Label`.

- Label
  - intrinsic
    - name: String (subject to syntax check)
  - extrinsic
    - attachedTo: any Element? (dependent on the previous elements when situated in a content)

- Reference
  - intrinsic
    - labelName: String
  - extrinsic
    - label: Label? (depedent on the whole document)
