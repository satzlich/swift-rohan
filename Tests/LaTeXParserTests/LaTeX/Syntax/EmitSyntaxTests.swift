// Copyright 2024-2025 Lie Yan

import LaTeXParser
import Testing

struct EmitSyntaxTests {

  @Test
  func text() {
    // xyz

    // phase 0: emit from constituent

    // xyz -> text

    // phase 1: wrap for combination

    // (skip)

    // phase 2: emit

    // text -> streamlet
  }

  @Test
  func accent() {
    // \widetilde{xyz}

    // phase 0: emit from constituents

    // xyz -> stream
    // \widetilde -> command-seq token

    // phase 1: wrap for combination

    // xyz -> stream -> group -> component
    // \widetilde -> command-seq token

    // phase 2: emit

    // command-seq token + component -> command seq -> streamlet
  }
  
  @Test
  func attach() {
    
  }

  @Test
  func frac() {
    // \frac{x+y}{z}

    // phase 0: emit from constituents

    // x+y -> stream
    // z -> stream
    // \frac -> command-seq token

    // phase 1: wrap for combination

    // x+y -> stream -> group -> component
    // z -> stream -> group -> component
    // \frac -> command-seq token

    // phase 2: emit

    // command-seq token + component + component -> command seq -> streamlet
  }
}
