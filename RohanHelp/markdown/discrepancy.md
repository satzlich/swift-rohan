---
title: "Discrepancies"
css: styles.css
---


The app handles certain commands differently from standard LaTeX due to their 
non-hierarchical structure. Below are key differences and usage guidelines.

## Prime Marks (`'`)

- **Simple primes**
  - `x'` and `x\prime` work identically in both LaTeX and the app
- **Mixed formulas** (primes with super-/subscripts)
  - For `x''^m`, use `x^{''m}` in the app
  - For `x''_n`, use `x^{''}_n` in the app

## `\limits` and `\nolimits`

- **Syntax Structure**
   - **LaTeX**: Postfix notation (e.g., `\sum\nolimits`)
   - **App**: Command-call notation — insert `\limits` or `\nolimits` before typing the operator

- **Export Behavior**
   - The app auto-corrects positioning during LaTeX export
   - Avoid edge cases like `\sum\nolimits\limits`; results may deviate from expectations in minute ways. Besides, it's not a good practice to consciously introduce redundant commands in both LaTeX and the app.

## Navigation

- **LaTeX**: Source code is plain text
- **App**: Math components are linearized:
  - Use arrow keys to traverse every editable part
  - Aligns with Microsoft Word's equation editor behavior
