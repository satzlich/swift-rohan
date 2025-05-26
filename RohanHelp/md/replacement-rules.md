# Replacement Rules

Replacement rules are used to convert the text entered by the user into another entity.

Rules are either triggered immediately or when the user presses the space key (`␣`).

## Text Mode Rules (12)

The following rules are applied when the cursor is in text area:

|                 Pattern | Replacement | Look                   |
| ----------------------: | :---------- | :--------------------- |
|      <code>&#96;</code> | ‘           | ‘                      |
| <code>&#96;&#96;</code> | “           | “                      |
|                     `'` | ’           | ’                      |
|                    `''` | ”           | “                      |
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

### Basic (6)

| Pattern | Replacement        | Look     |
| ------: | :----------------- | -------- |
|     `$` | inline math        |          |
|     `^` | attach superscript | $x^{⬚}$  |
|     `_` | attach subscript   | $x_{⬚}$  |
|     `'` | ′ (prime)          | $\prime$ |
|    `''` | ″ (double prime)   | $″$      |
|   `'''` | ‴ (triple prime)   | $‴$      |

### Miscellaneous (4)

| Pattern | Replacement | Look           |
| ------: | :---------- | :------------- |
|   `...` | `\ldots`    | $\ldots$       |
|   `oo␣` | `\infty`    | $\infty$       |
|   `xx␣` | `\times`    | $\times$       |
|  `mod␣` | `\bmod`     | $\mathrm{mod}$ |

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

### Left-right delimiters (7)

|                   Pattern | Replacement                  | Look                         |
| ------------------------: | :--------------------------- | :--------------------------- |
|                      `()` | `\left(       \right)`       | $\left(⬚\right)$             |
|                      `[]` | `\left[       \right]`       | $\left[⬚\right]$             |
|                      `{}` | `\left\{      \right\}`      | $\left\{⬚\right\}$           |
|                      `[)` | `\left[       \right)`       | $\left[⬚\right)$             |
|                      `(]` | `\left(       \right]`       | $\left(⬚\right]$             |
|                      `<>` | `\left\langle \right\rangle` | $\left\langle⬚\right\rangle$ |
| <code>&#124;&#124;</code> | `\left\lvert  \right\rvert`  | $\left\lvert⬚\right\rvert$   |

Note: For $\left\lVert⬚\right\rVert$, $\left\lfloor⬚\right\rfloor$, $\left\lceil⬚\right\rceil$,
use command `\norm`, `\floor`, `\ceil` respectively.

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

### Styled letters (234)

| Pattern | Replacement    | Look           |
| ------: | :------------- | :------------- |
|  `bbA␣` | `\mathbf{A}`   | $\mathbf{A}$   |
|       ⋮ |                |                |
|  `bbZ␣` | `\mathbf{Z}`   | $\mathbf{Z}$   |
|  `bba␣` | `\mathbf{a}`   | $\mathbf{a}$   |
|       ⋮ |                |                |
|  `bbz␣` | `\mathbf{z}`   | $\mathbf{z}$   |
| `bbbA␣` | `\mathbb{A}`   | $\mathbb{A}$   |
|       ⋮ |                |                |
| `bbbZ␣` | `\mathbb{Z}`   | $\mathbb{Z}$   |
|  `ccA␣` | `\mathcal{A}`  | $\mathcal{A}$  |
|       ⋮ |                |                |
|  `ccZ␣` | `\mathcal{Z}`  | $\mathcal{Z}$  |
|  `frA␣` | `\mathfrak{A}` | $\mathfrak{A}$ |
|       ⋮ |                |                |
|  `frZ␣` | `\mathfrak{Z}` | $\mathfrak{Z}$ |
|  `sfA␣` | `\mathsf{A}`   | $\mathsf{A}$   |
|       ⋮ |                |                |
|  `sfZ␣` | `\mathsf{Z}`   | $\mathsf{Z}$   |
|  `sfa␣` | `\mathsf{a}`   | $\mathsf{a}$   |
|       ⋮ |                |                |
|  `sfz␣` | `\mathsf{z}`   | $\mathsf{z}$   |
|  `ttA␣` | `\mathtt{A}`   | $\mathtt{A}$   |
|       ⋮ |                |                |
|  `ttZ␣` | `\mathtt{Z}`   | $\mathtt{Z}$   |
|  `tta␣` | `\mathtt{a}`   | $\mathtt{a}$   |
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
