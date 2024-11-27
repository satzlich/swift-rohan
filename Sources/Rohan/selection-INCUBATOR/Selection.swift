// Copyright 2024 Lie Yan

import Foundation

/*

 - selectable
    - normal or sticky
 - copyable
 - deletable

 
 Consider `apply` and `variable`
 
 */

enum MarkerType {
    case text(offset: Int)
    case element(offset: Int)
    case cell(offset: Int)
    case math
}
