---
title: "Replacement Rules"
css: styles.css
---

Replacement rules are used to convert the text entered by the user into another entity.

Rules are either triggered immediately or when the user presses the space key (`␣`).

## Text Mode Rules (12)

The following rules are applied when the cursor is in text area:

|                 Pattern | Replacement | Look                   |
| ----------------------: | :---------- | :--------------------- |
|      <code>&#96;</code> | ‘           | $\text{‘}$             |
| <code>&#96;&#96;</code> | “           | $\text{“}$             |
|                     `'` | ’           | $\text{’}$             |
|                    `''` | ”           | $\text{“}$             |
|                    `--` | – (en dash) | –                      |
|                   `---` | — (em dash) | —                      |
|                   `...` | …           | …                      |
|                    `#␣` | `<h1>`      | ![](images/h1.svg)     |
|                   `##␣` | `<h2>`      | ![](images/h2.svg)     |
|                  `###␣` | `<h3>`      | ![](images/h3.svg)     |
|                    `*␣` | _emph_      | ![](images/emph.svg)   |
|                   `**␣` | **strong**  | ![](images/strong.svg) |

## Math Mode Rules

The following rules are applied when the cursor is in math area:

### Basic (7)

| Pattern | Replacement         | Look     |
| ------: | :------------------ | -------- |
|     `$` | inline math         |          |
|     `^` | attach superscript  | $x^{⬚}$  |
|     `_` | attach subscript    | $x_{⬚}$  |
|     `'` | ′ (prime)           | $\prime$ |
|    `''` | ″ (double prime)    | $″$      |
|   `'''` | ‴ (triple prime)    | $‴$      |
|  `''''` | ⁗ (quadruple prime) | $⁗$      |

### Miscellaneous (4)

| Pattern | Replacement | Look           | Note                          |
| ------: | :---------- | :------------- | :---------------------------- |
|   `...` | `\ldots`    | $\ldots$       |                               |
|   `oo␣` | `\infty`    | $\infty$       |                               |
|   `xx␣` | `\times`    | $\times$       |                               |
|  `mod␣` | `\bmod`     | $\mathrm{mod}$ | `\bmod` is a binary operator. |

### Inequalities (3)

| Pattern | Replacement | Look   |
| ------: | :---------- | :----- |
|    `/=` | `\neq`      | $\neq$ |
|    `<=` | `\leq`      | $\leq$ |
|    `>=` | `\geq`      | $\geq$ |

### Arrows (5)

| Pattern | Replacement       | Look              |
| ------: | :---------------- | :---------------- |
|    `<-` | `\leftarrow`      | $\leftarrow$      |
|    `->` | `\rightarrow`     | $\rightarrow$     |
|    `=>` | `\Rightarrow`     | $\Rightarrow$     |
|   `-->` | `\longrightarrow` | $\longrightarrow$ |
|   `==>` | `\Longrightarrow` | $\Longrightarrow$ |

### Left-right delimiters (144)

The following table lists the left and right delimiters that can be used in math mode.

| Left Delimiter | Right Delimiter |
| -------------- | --------------- |
| `(`            | `)`             |
| `[`            | `]`             |
| `{`            | `}`             |
| `\langle`      | `\rangle`       |
| `\lbrace`      | `\rbrace`       |
| `\lbrack`      | `\rbrack`       |
| `\lceil`       | `\rceil`        |
| `\lfloor`      | `\rfloor`       |
| `\lgroup`      | `\rgroup`       |
| `\lmoustache`  | `\rmoustache`   |
| `\lvert`       | `\rvert`        |
| `\lVert`       | `\rVert`        |

Left and right delimiters can be combined to create $12\times 12$ different pairs of delimiters.

|         Pattern | Replacement                | Look                       |
| --------------: | :------------------------- | :------------------------- |
|           `()␣` | `\left(      \right)`      | $\left(⬚\right)$           |
|           `(]␣` | `\left(      \right]`      | $\left(⬚\right]$           |
|               ⋮ |                            |                            |
| `\lVert\rVert␣` | `\left\lVert \right\rVert` | $\left\lVert⬚\right\rVert$ |

In addition, code snippets `\norm`, `\floor`, and `\ceil` can be used to create norm $\left\lVert⬚\right\rVert$, floor $\left\lfloor⬚\right\rfloor$, and ceiling $\left\lceil⬚\right\rceil$ delimiters respectively.

### Set operations (5)

| Pattern | Replacement | Look        | Note                 |
| ------: | :---------- | :---------- | -------------------- |
|  `cap␣` | `\cap`      | $\cap$      |                      |
|  `cup␣` | `\cup`      | $\cup$      |                      |
|   `in␣` | `\in`       | $\in$       |                      |
|  `sub␣` | `\subset`   | $\subset$   | `sup␣` is for `\sup` |
| `sube␣` | `\subseteq` | $\subseteq$ |                      |

### Sum-like operators (4)

| Pattern | Replacement | Look    |
| ------: | :---------- | :------ |
|  `sum␣` | `\sum`      | $\sum$  |
| `prod␣` | `\prod`     | $\prod$ |
|  `int␣` | `\int`      | $\int$  |
| `oint␣` | `\oint`     | $\oint$ |

### Greek letters (29)

Greek letters each with name of length 5 or less.

|  Pattern | Replacement | Look     |
| -------: | :---------- | :------- |
| `alpha␣` | `\alpha`    | $\alpha$ |
|  `beta␣` | `\beta`     | $\beta$  |
|   `chi␣` | `\chi`      | $\chi$   |
| `delta␣` | `\delta`    | $\delta$ |
|   `eta␣` | `\eta`      | $\eta$   |
| `gamma␣` | `\gamma`    | $\gamma$ |
|  `iota␣` | `\iota`     | $\iota$  |
| `kappa␣` | `\kappa`    | $\kappa$ |
|    `mu␣` | `\mu`       | $\mu$    |
|    `nu␣` | `\nu`       | $\nu$    |
| `omega␣` | `\omega`    | $\omega$ |
|   `phi␣` | `\phi`      | $\phi$   |
|    `pi␣` | `\pi`       | $\pi$    |
|   `psi␣` | `\psi`      | $\psi$   |
|   `rho␣` | `\rho`      | $\rho$   |
| `sigma␣` | `\sigma`    | $\sigma$ |
|   `tau␣` | `\tau`      | $\tau$   |
| `theta␣` | `\theta`    | $\theta$ |
|    `xi␣` | `\xi`       | $\xi$    |
|  `zeta␣` | `\zeta`     | $\zeta$  |
| `Delta␣` | `\Delta`    | $\Delta$ |
| `Gamma␣` | `\Gamma`    | $\Gamma$ |
| `Omega␣` | `\Omega`    | $\Omega$ |
|   `Phi␣` | `\Phi`      | $\Phi$   |
|    `Pi␣` | `\Pi`       | $\Pi$    |
|   `Psi␣` | `\Psi`      | $\Psi$   |
| `Sigma␣` | `\Sigma`    | $\Sigma$ |
| `Theta␣` | `\Theta`    | $\Theta$ |
|    `Xi␣` | `\Xi`       | $\Xi$    |

### Styled letters (312)

| Pattern | Replacement    | Look           |
| ------: | :------------- | :------------- |
|  `bbA␣` | `\mathbf{A}`   | $\mathbf{A}$   |
|       ⋮ |                |                |
|  `bbz␣` | `\mathbf{z}`   | $\mathbf{z}$   |
| `bbbA␣` | `\mathbb{A}`   | $\mathbb{A}$   |
|       ⋮ |                |                |
| `bbbz␣` | `\mathbb{Z}`   | $\mathbb{z}$   |
|  `ccA␣` | `\mathcal{A}`  | $\mathcal{A}$  |
|       ⋮ |                |                |
|  `ccz␣` | `\mathcal{Z}`  | $\mathcal{z}$  |
|  `frA␣` | `\mathfrak{A}` | $\mathfrak{A}$ |
|       ⋮ |                |                |
|  `frz␣` | `\mathfrak{Z}` | $\mathfrak{z}$ |
|  `sfA␣` | `\mathsf{A}`   | $\mathsf{A}$   |
|       ⋮ |                |                |
|  `sfz␣` | `\mathsf{z}`   | $\mathsf{z}$   |
|  `ttA␣` | `\mathtt{A}`   | $\mathtt{A}$   |
|       ⋮ |                |                |
|  `ttz␣` | `\mathtt{z}`   | $\mathtt{z}$   |

### Math Operators (43)

|    Pattern | Replacement | Look            |
| ---------: | :---------- | :-------------- |
|  `arccos␣` | `\arccos`   | $\arccos$       |
|  `arcsin␣` | `\arcsin`   | $\arcsin$       |
|  `arctan␣` | `\arctan`   | $\arctan$       |
|     `arg␣` | `\arg`      | $\arg$          |
|     `cos␣` | `\cos`      | $\cos$          |
|    `cosh␣` | `\cosh`     | $\cosh$         |
|     `cot␣` | `\cot`      | $\cot$          |
|    `coth␣` | `\coth`     | $\coth$         |
|     `csc␣` | `\csc`      | $\csc$          |
|    `csch␣` | `\csch`     | $\mathrm{csch}$ |
|     `ctg␣` | `\ctg`      | $\mathrm{ctg}$  |
|     `deg␣` | `\deg`      | $\deg$          |
|     `det␣` | `\det`      | $\det$          |
|     `dim␣` | `\dim`      | $\dim$          |
|     `exp␣` | `\exp`      | $\exp$          |
|     `gcd␣` | `\gcd`      | $\gcd$          |
|     `hom␣` | `\hom`      | $\hom$          |
|      `id␣` | `\id`       | $\mathrm{id}$   |
|      `im␣` | `\im`       | $\mathrm{im}$   |
|     `inf␣` | `\inf`      | $\inf$          |
|  `injlim␣` | `\injlim`   | $\injlim$       |
|     `lcm␣` | `\lcm`      | $\mathrm{lcm}$  |
|     `ker␣` | `\ker`      | $\ker$          |
|      `lg␣` | `\lg`       | $\lg$           |
|     `lim␣` | `\lim`      | $\lim$          |
|  `liminf␣` | `\liminf`   | $\liminf$       |
|  `limsup␣` | `\limsup`   | $\limsup$       |
|      `ln␣` | `\ln`       | $\ln$           |
|     `log␣` | `\log`      | $\log$          |
|     `max␣` | `\max`      | $\max$          |
|     `min␣` | `\min`      | $\min$          |
|      `Pr␣` | `\Pr`       | $\Pr$           |
| `projlim␣` | `\projlim`  | $\projlim$      |
|     `sec␣` | `\sec`      | $\sec$          |
|    `sech␣` | `\sech`     | $\mathrm{sech}$ |
|     `sin␣` | `\sin`      | $\sin$          |
|    `sinc␣` | `\sinc`     | $\mathrm{sinc}$ |
|    `sinh␣` | `\sinh`     | $\sinh$         |
|     `sup␣` | `\sup`      | $\sup$          |
|     `tan␣` | `\tan`      | $\tan$          |
|    `tanh␣` | `\tanh`     | $\tanh$         |
|      `tg␣` | `\tg`       | $\mathrm{tg}$   |
|      `tr␣` | `\tr`       | $\mathrm{tr}$   |

## Stability of Replacement Rules

The replacement rules are stable in the sense that they are not expected to change frequently.
However, they can be updated as needed to improve the overall editing experience.
