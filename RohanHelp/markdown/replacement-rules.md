---
title: "Replacement Rules"
css: styles.css
---

Replacement rules are used to convert the text entered by the user into another entity.

Rules are either triggered immediately or when the user presses the space key (`␣`).

## Text Mode Rules

The following rules are applied when the cursor is in text area:

|  \# |                 Pattern | Replacement | Look                   |
| --: | ----------------------: | :---------- | :--------------------- |
|   1 |      <code>&#96;</code> | ‘           | $\text{‘}$             |
|   2 | <code>&#96;&#96;</code> | “           | $\text{“}$             |
|   3 |                     `'` | ’           | $\text{’}$             |
|   4 |                    `''` | ”           | $\text{“}$             |
|   5 |                    `--` | – (en dash) | –                      |
|   6 |                   `---` | — (em dash) | —                      |
|   7 |                   `...` | …           | …                      |
|   8 |                    `#␣` | `<h1>`      | ![](images/h1.svg)     |
|   9 |                   `##␣` | `<h2>`      | ![](images/h2.svg)     |
|  10 |                  `###␣` | `<h3>`      | ![](images/h3.svg)     |
|  11 |                    `*␣` | _emph_      | ![](images/emph.svg)   |
|  12 |                   `**␣` | **strong**  | ![](images/strong.svg) |

## Math Mode Rules

The following rules are applied when the cursor is in math area:

### Basic

|  \# | Pattern | Replacement         | Look     |
| --: | ------: | :------------------ | -------- |
|   1 |     `$` | inline math         |          |
|   2 |     `^` | attach superscript  | $x^{⬚}$  |
|   3 |     `_` | attach subscript    | $x_{⬚}$  |
|   4 |     `'` | ′ (prime)           | $\prime$ |
|   5 |    `''` | ″ (double prime)    | $″$      |
|   6 |   `'''` | ‴ (triple prime)    | $‴$      |
|   7 |  `''''` | ⁗ (quadruple prime) | $⁗$      |

### Miscellaneous

|  \# |  Pattern | Replacement   | Look           | Note                          |
| --: | -------: | :------------ | :------------- | :---------------------------- |
|   1 |    `...` | `\ldots`      | $\ldots$       |                               |
|   2 | `cdots␣` | `\cdots`      | $\cdots$       |                               |
|   3 |  `frac␣` | `\frac{⬚}{⬚}` | $\frac{⬚}{⬚}$  |                               |
|   4 |    `oo␣` | `\infty`      | $\infty$       |                               |
|   5 |    `xx␣` | `\times`      | $\times$       |                               |
|   6 |   `mod␣` | `\bmod`       | $\mathrm{mod}$ | `\bmod` is a binary operator. |

### Inequalities

|  \# | Pattern | Replacement | Look   |
| --: | ------: | :---------- | :----- |
|   1 |    `/=` | `\neq`      | $\neq$ |
|   2 |    `<=` | `\leq`      | $\leq$ |
|   3 |    `>=` | `\geq`      | $\geq$ |

### Arrows

|  \# | Pattern | Replacement       | Look              |
| --: | ------: | :---------------- | :---------------- |
|   1 |    `<-` | `\leftarrow`      | $\leftarrow$      |
|   2 |    `->` | `\rightarrow`     | $\rightarrow$     |
|   3 |    `=>` | `\Rightarrow`     | $\Rightarrow$     |
|   4 |   `-->` | `\longrightarrow` | $\longrightarrow$ |
|   5 |   `==>` | `\Longrightarrow` | $\Longrightarrow$ |

### Left-right delimiters

The following table lists the left and right delimiters that can be used in math mode.

|  \# | Left Delimiter | Right Delimiter |
| --: | -------------- | --------------- |
|   1 | `(`            | `)`             |
|   2 | `[`            | `]`             |
|   3 | `{`            | `}`             |
|   4 | `\langle`      | `\rangle`       |
|   5 | `\lbrace`      | `\rbrace`       |
|   6 | `\lbrack`      | `\rbrack`       |
|   7 | `\lceil`       | `\rceil`        |
|   8 | `\lfloor`      | `\rfloor`       |
|   9 | `\lgroup`      | `\rgroup`       |
|  10 | `\lmoustache`  | `\rmoustache`   |
|  11 | `\lvert`       | `\rvert`        |
|  12 | `\lVert`       | `\rVert`        |

Left and right delimiters can be combined to create $12\times 12$ different pairs of delimiters.

|  \# |         Pattern | Replacement                | Look                       |
| --: | --------------: | :------------------------- | :------------------------- |
|   1 |           `()␣` | `\left(      \right)`      | $\left(⬚\right)$           |
|   2 |           `(]␣` | `\left(      \right]`      | $\left(⬚\right]$           |
|   ⋮ |               ⋮ | ⋮                          | ⋮                          |
| 144 | `\lVert\rVert␣` | `\left\lVert \right\rVert` | $\left\lVert⬚\right\rVert$ |

In addition, the following patterns can also be used to create left and right delimiters:

|  \# |                                Pattern | Replacement                      | Look                           |
| --: | -------------------------------------: | :------------------------------- | :----------------------------- |
| 145 |                                  `<>␣` | `\left\langle     \right\rangle` | $\left\langle ⬚ \right\rangle$ |
| 146 |             <code>&#124;&#124;␣</code> | `\left\lvert      \right\rvert`  | $\left\lvert ⬚ \right\rvert$   |
| 147 | <code>&#124;&#124;&#124;&#124;␣</code> | `\left\lVert      \right\rVert`  | $\left\lVert ⬚ \right\rVert$   |

See also [Code Snippets](code-snippets.html) section for code snippets that can be used to create left and right delimiters.

### Set operations

|  \# | Pattern | Replacement | Look        | Note                 |
| --: | ------: | :---------- | :---------- | -------------------- |
|   1 |  `cap␣` | `\cap`      | $\cap$      |                      |
|   2 |  `cup␣` | `\cup`      | $\cup$      |                      |
|   3 |   `in␣` | `\in`       | $\in$       |                      |
|   4 |  `sub␣` | `\subset`   | $\subset$   | `sup␣` is for `\sup` |
|   5 | `sube␣` | `\subseteq` | $\subseteq$ |                      |

### Sum-like operators

|  \# | Pattern | Replacement | Look    |
| --: | ------: | :---------- | :------ |
|   1 |  `sum␣` | `\sum`      | $\sum$  |
|   2 | `prod␣` | `\prod`     | $\prod$ |
|   3 |  `int␣` | `\int`      | $\int$  |
|   4 | `oint␣` | `\oint`     | $\oint$ |

### Greek letters

Greek letters with names of five or fewer characters can be entered directly.

|  \# |  Pattern | Replacement | Look     |
| --: | -------: | :---------- | :------- |
|   1 | `alpha␣` | `\alpha`    | $\alpha$ |
|   2 |  `beta␣` | `\beta`     | $\beta$  |
|   3 |   `chi␣` | `\chi`      | $\chi$   |
|   4 | `delta␣` | `\delta`    | $\delta$ |
|   5 |   `eta␣` | `\eta`      | $\eta$   |
|   6 | `gamma␣` | `\gamma`    | $\gamma$ |
|   7 |  `iota␣` | `\iota`     | $\iota$  |
|   8 | `kappa␣` | `\kappa`    | $\kappa$ |
|   9 |    `mu␣` | `\mu`       | $\mu$    |
|  10 |    `nu␣` | `\nu`       | $\nu$    |
|  11 | `omega␣` | `\omega`    | $\omega$ |
|  12 |   `phi␣` | `\phi`      | $\phi$   |
|  13 |    `pi␣` | `\pi`       | $\pi$    |
|  14 |   `psi␣` | `\psi`      | $\psi$   |
|  15 |   `rho␣` | `\rho`      | $\rho$   |
|  16 | `sigma␣` | `\sigma`    | $\sigma$ |
|  17 |   `tau␣` | `\tau`      | $\tau$   |
|  18 | `theta␣` | `\theta`    | $\theta$ |
|  19 | `varpi␣` | `\varpi`    | $\varpi$ |
|  20 |    `xi␣` | `\xi`       | $\xi$    |
|  21 |  `zeta␣` | `\zeta`     | $\zeta$  |
|  22 | `Delta␣` | `\Delta`    | $\Delta$ |
|  23 | `Gamma␣` | `\Gamma`    | $\Gamma$ |
|  24 | `Omega␣` | `\Omega`    | $\Omega$ |
|  25 |   `Phi␣` | `\Phi`      | $\Phi$   |
|  26 |    `Pi␣` | `\Pi`       | $\Pi$    |
|  27 |   `Psi␣` | `\Psi`      | $\Psi$   |
|  28 | `Sigma␣` | `\Sigma`    | $\Sigma$ |
|  29 | `Theta␣` | `\Theta`    | $\Theta$ |
|  30 |    `Xi␣` | `\Xi`       | $\Xi$    |

For epsilon, we provide shortcuts for both the standard and variant forms.

|  \# | Pattern | Replacement   | Look          |
| --: | ------: | :------------ | :------------ |
|  31 |  `eps␣` | `\epsilon`    | $\epsilon$    |
|  32 | `veps␣` | `\varepsilon` | $\varepsilon$ |

### Styled letters

|  \# | Pattern | Replacement    | Look           |
| --: | ------: | :------------- | :------------- |
|   1 |  `bbA␣` | `\mathbf{A}`   | $\mathbf{A}$   |
|   ⋮ |       ⋮ | ⋮              | ⋮              |
|  52 |  `bbz␣` | `\mathbf{z}`   | $\mathbf{z}$   |
|  53 | `bbbA␣` | `\mathbb{A}`   | $\mathbb{A}$   |
|   ⋮ |       ⋮ | ⋮              | ⋮              |
| 104 | `bbbz␣` | `\mathbb{Z}`   | $\mathbb{z}$   |
| 105 |  `ccA␣` | `\mathcal{A}`  | $\mathcal{A}$  |
|   ⋮ |       ⋮ | ⋮              | ⋮              |
| 156 |  `ccz␣` | `\mathcal{Z}`  | $\mathcal{z}$  |
| 157 |  `frA␣` | `\mathfrak{A}` | $\mathfrak{A}$ |
|   ⋮ |       ⋮ | ⋮              | ⋮              |
| 208 |  `frz␣` | `\mathfrak{Z}` | $\mathfrak{z}$ |
| 209 |  `sfA␣` | `\mathsf{A}`   | $\mathsf{A}$   |
|   ⋮ |       ⋮ | ⋮              | ⋮              |
| 260 |  `sfz␣` | `\mathsf{z}`   | $\mathsf{z}$   |
| 261 |  `ttA␣` | `\mathtt{A}`   | $\mathtt{A}$   |
|   ⋮ |       ⋮ | ⋮              | ⋮              |
| 312 |  `ttz␣` | `\mathtt{z}`   | $\mathtt{z}$   |

### Math Operators

|  \# |    Pattern | Replacement | Look            |
| --: | ---------: | :---------- | :-------------- |
|   1 |  `arccos␣` | `\arccos`   | $\arccos$       |
|   2 |  `arcsin␣` | `\arcsin`   | $\arcsin$       |
|   3 |  `arctan␣` | `\arctan`   | $\arctan$       |
|   4 |     `arg␣` | `\arg`      | $\arg$          |
|   5 |     `cos␣` | `\cos`      | $\cos$          |
|   6 |    `cosh␣` | `\cosh`     | $\cosh$         |
|   7 |     `cot␣` | `\cot`      | $\cot$          |
|   8 |    `coth␣` | `\coth`     | $\coth$         |
|   9 |     `csc␣` | `\csc`      | $\csc$          |
|  10 |    `csch␣` | `\csch`     | $\mathrm{csch}$ |
|  11 |     `ctg␣` | `\ctg`      | $\mathrm{ctg}$  |
|  12 |     `deg␣` | `\deg`      | $\deg$          |
|  13 |     `det␣` | `\det`      | $\det$          |
|  14 |     `dim␣` | `\dim`      | $\dim$          |
|  15 |     `exp␣` | `\exp`      | $\exp$          |
|  16 |     `gcd␣` | `\gcd`      | $\gcd$          |
|  17 |     `hom␣` | `\hom`      | $\hom$          |
|  18 |      `id␣` | `\id`       | $\mathrm{id}$   |
|  19 |      `im␣` | `\im`       | $\mathrm{im}$   |
|  20 |     `inf␣` | `\inf`      | $\inf$          |
|  21 |  `injlim␣` | `\injlim`   | $\injlim$       |
|  22 |     `lcm␣` | `\lcm`      | $\mathrm{lcm}$  |
|  23 |     `ker␣` | `\ker`      | $\ker$          |
|  24 |      `lg␣` | `\lg`       | $\lg$           |
|  25 |     `lim␣` | `\lim`      | $\lim$          |
|  26 |  `liminf␣` | `\liminf`   | $\liminf$       |
|  27 |  `limsup␣` | `\limsup`   | $\limsup$       |
|  28 |      `ln␣` | `\ln`       | $\ln$           |
|  29 |     `log␣` | `\log`      | $\log$          |
|  30 |     `max␣` | `\max`      | $\max$          |
|  31 |     `min␣` | `\min`      | $\min$          |
|  32 |      `Pr␣` | `\Pr`       | $\Pr$           |
|  33 | `projlim␣` | `\projlim`  | $\projlim$      |
|  34 |     `sec␣` | `\sec`      | $\sec$          |
|  35 |    `sech␣` | `\sech`     | $\mathrm{sech}$ |
|  36 |     `sin␣` | `\sin`      | $\sin$          |
|  37 |    `sinc␣` | `\sinc`     | $\mathrm{sinc}$ |
|  38 |    `sinh␣` | `\sinh`     | $\sinh$         |
|  39 |     `sup␣` | `\sup`      | $\sup$          |
|  40 |     `tan␣` | `\tan`      | $\tan$          |
|  41 |    `tanh␣` | `\tanh`     | $\tanh$         |
|  42 |      `tg␣` | `\tg`       | $\mathrm{tg}$   |
|  43 |      `tr␣` | `\tr`       | $\mathrm{tr}$   |

## Stability of Replacement Rules

The replacement rules are stable in the sense that they are not expected to change frequently.
However, they can be updated as needed to improve the overall editing experience.

If time permits, we will provide customization options for replacement rules in future releases,
allowing users to define their own patterns and replacements.
