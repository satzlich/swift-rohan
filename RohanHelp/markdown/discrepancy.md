---
title: "Discrepancies"
css: styles.css
---

The app handles certain commands differently from standard LaTeX due to their non-hierarchical nature
or other irregularities. Below are key differences and usage guidelines.

## Prime Marks (`'`)

- **Simple primes**
  - `x'`, `x''`, `x'''`, `x''''` and `x\prime` work identically in both LaTeX and the app
- **Mixed formulas** (primes with super-/subscripts)
  - For `x''^m`, use `x^{''m}` in the app
  - For `x''_n`, use `x^{''}_n` in the app
- **Export Behavior**
  - Primes are exported as `\prime`, `\dprime`, `\trprime` and `\qprime` in LaTeX respectively according to their number. Primes more than four are not supported.

> Commands `\dprime`, `\trprime`, and `\qprime` are provided by `unicode-math` package. In the case when `unicode-math` is unavailable,
> declare custom commands in the preamble:
>
> ```latex
> \newcommand{\dprime}{\ensuremath{''}}
> \newcommand{\trprime}{\ensuremath{'''}}
> \newcommand{\qprime}{\ensuremath{''''}}
> ```

## Command `\limits` and `\nolimits`

- **Syntax Structure**

  - **LaTeX**: Postfix notation (e.g., `\sum\nolimits`)
  - **App**: Function call notation — insert `\limits` or `\nolimits` before typing the operator

- **Export Behavior**
  - The app auto-corrects positioning during LaTeX export
  - Avoid edge cases like `\sum\nolimits\limits`; results may deviate from expectations in subtle ways. Besides, it's a bad practice to consciously introduce redundant commands whether in LaTeX or the app.

## Environment `{itemize}` and `{enumerate}`

Currently we support only one-level lists in the app. We will go back to this later and add support for nested lists.
