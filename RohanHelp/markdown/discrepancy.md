---
title: "Discrepancy"
css: styles.css
---

Discrepancies exist between the app's treatment and standard LaTeX commands.
Below are the key differences to note:

## Prime Marks (')

- **Simple primes** like `x'` and `x\prime` have direct counterparts in the app.
- **Mixed formulas** combining primes with super-/subscripts (e.g., `x''^m` or `x''_n`) require adjusted syntax:
  - Use `x^{''m}` for `x''^m`.
  - Use `x^{''}_n` for `x''_n`.

## Limit Commands

The app handles `\limits` and `\nolimits` differently from standard LaTeX.

1. **Syntax Structure**:

   - **LaTeX**: Uses postfix notation (e.g., `\sum\nolimits`)
   - **App**: Uses command call notation - `\limits` or `\nolimits` creates a placeholder where the operator can be placed.

2. **Export Behavior**:
   - When exporting to LaTeX, `\limits` and `\nolimits` are automatically placed in the correct position.

## Navigation

LaTeX source code is represented as plain text, making navigation straightforward.

In this app, mathematical components are linearized, allowing the cursor to move 
through every editable part of a math expression using the left/right arrow keys.
This approach aligns with the equation editor in Microsoft Word.

