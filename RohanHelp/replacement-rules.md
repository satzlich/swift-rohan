
# Replacement Rules

Replacement rules are used to convert the text entered by the user into another entity.

Rules are either triggered immediately or when the user presses the space key (`␣`).

## Text Mode Rules (12)

The following rules are applied when the cursor is in text area:

|            Pattern | Replacement            | Look                   |
| -----------------: | :--------------------- | :--------------------- |
|     \` (backquote) | ‘ (left single quote)  | ‘                      |
|               \`\` | “ (left double quote)  | “                      |
| `'` (single quote) | ’ (right single quote) | ’                      |
|               `''` | ” (right double quote) | “                      |
|               `--` | – (en dash)            | –                      |
|              `---` | — (em dash)            | —                      |
|              `...` | … (ellipsis)           | …                      |
|               `#␣` | h1                     | ![](images/h1.svg)     |
|              `##␣` | h2                     | ![](images/h2.svg)     |
|             `###␣` | h3                     | ![](images/h3.svg)     |
|               `*␣` | *emph*                 | ![](images/emph.svg)   |
|              `**␣` | **strong**             | ![](images/strong.svg) |


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


### Miscellaneous (3)

| Pattern | Replacement | Look     |
| ------: | :---------- | :------- |
|   `...` | `\ldots`    | $\ldots$ |
|   `oo␣` | `\infty`    | $\infty$ |
|   `xx␣` | `\times`    | $\times$ |

### Inequalities (3)

| Pattern | Replacement | Look   |
| ------: | :---------- | :----- |
|    `!=` | `\neq`      | $\neq$ |
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


|       Pattern | Replacement                  | Look                         |
| ------------: | :--------------------------- | :--------------------------- |
|          `()` | `\left(       \right)`       | $\left(⬚\right)$             |
|          `[]` | `\left[       \right]`       | $\left[⬚\right]$             |
|          `{}` | `\left\{      \right\}`      | $\left\{⬚\right\}$           |
|          `[)` | `\left[       \right)`       | $\left[⬚\right)$             |
|          `(]` | `\left(       \right]`       | $\left(⬚\right]$             |
|          `<>` | `\left\langle \right\rangle` | $\left\langle⬚\right\rangle$ |
| &#124; &#124; | `\left\lvert  \right\rvert`  | $\left\lvert⬚\right\rvert$   |

Note: For $\left\lVert⬚\right\rVert$, $\left\lfloor⬚\right\rfloor$, $\left\lceil⬚\right\rceil$, 
use command `\norm`, `\floor`, `\ceil` respectively.


### Set operations (5)

| Pattern | Replacement | Look        | Note                |
| ------: | :---------- | :---------- | ------------------- |
|  `cap␣` | `\cap`      | $\cap$      |                     |
|  `cup␣` | `\cup`      | $\cup$      |                     |
|   `in␣` | `\in`       | $\in$       |                     |
|  `sub␣` | `\subset`   | $\subset$   | `sup` is for `\sup` |
| `sube␣` | `\subseteq` | $\subseteq$ |                     |

### Sum-like operators (4)

| Pattern | Replacement | Look    |
| ------: | :---------- | :------ |
|  `sum␣` | `\sum`      | $\sum$  |
| `prod␣` | `\prod`     | $\prod$ |
|  `int␣` | `\int`      | $\int$  |
| `oint␣` | `\oint`     | $\oint$ |

### Greek letters (17)

Greek letters each with name of length 4 or less. 

| Pattern | Replacement | Look    |
| ------: | :---------- | :------ |
| `beta␣` | `\beta`     | $\beta$ |
|  `chi␣` | `\chi`      | $\chi$  |
|  `eta␣` | `\eta`      | $\eta$  |
| `iota␣` | `\iota`     | $\iota$ |
|   `mu␣` | `\mu`       | $\mu$   |
|   `nu␣` | `\nu`       | $\nu$   |
|  `phi␣` | `\phi`      | $\phi$  |
|   `pi␣` | `\pi`       | $\pi$   |
|  `psi␣` | `\psi`      | $\psi$  |
|  `rho␣` | `\rho`      | $\rho$  |
|  `tau␣` | `\tau`      | $\tau$  |
|   `xi␣` | `\xi`       | $\xi$   |
| `zeta␣` | `\zeta`     | $\zeta$ |
|  `Phi␣` | `\Phi`      | $\Phi$  |
|   `Pi␣` | `\Pi`       | $\Pi$   |
|  `Psi␣` | `\Psi`      | $\Psi$  |
|   `Xi␣` | `\Xi`       | $\Xi$   |


### Styled Letters (234)

| Pattern | Replacement    | Look           |
| ------: | :------------- | :------------- |
|  `bbA␣` | `\mathbf{A}`   | $\mathbf{A}$   |
|     ... |                |                |
|  `bbZ␣` | `\mathbf{Z}`   | $\mathbf{Z}$   |
|  `bba␣` | `\mathbf{a}`   | $\mathbf{a}$   |
|     ... |                |                |
|  `bbz␣` | `\mathbf{z}`   | $\mathbf{z}$   |
| `bbbA␣` | `\mathbb{A}`   | $\mathbb{A}$   |
|     ... |                |                |
| `bbbZ␣` | `\mathbb{Z}`   | $\mathbb{Z}$   |
|  `ccA␣` | `\mathcal{A}`  | $\mathcal{A}$  |
|     ... |                |                |
|  `ccZ␣` | `\mathcal{Z}`  | $\mathcal{Z}$  |
|  `frA␣` | `\mathfrak{A}` | $\mathfrak{A}$ |
|     ... |                |                |
|  `frZ␣` | `\mathfrak{Z}` | $\mathfrak{Z}$ |
|  `sfA␣` | `\mathsf{A}`   | $\mathsf{A}$   |
|     ... |                |                |
|  `sfZ␣` | `\mathsf{Z}`   | $\mathsf{Z}$   |
|  `sfa␣` | `\mathsf{a}`   | $\mathsf{a}$   |
|     ... |                |                |
|  `sfz␣` | `\mathsf{z}`   | $\mathsf{z}$   |
|  `ttA␣` | `\mathtt{A}`   | $\mathtt{A}$   |
|     ... |                |                |
|  `ttZ␣` | `\mathtt{Z}`   | $\mathtt{Z}$   |
|  `tta␣` | `\mathtt{a}`   | $\mathtt{a}$   |
|     ... |                |                |
|  `ttz␣` | `\mathtt{z}`   | $\mathtt{z}$   |


###  Math Operators (44) 

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
| `projlim␣` | `\projlim`  | $\projlim$      |
|     `ker␣` | `\ker`      | $\ker$          |
|      `lg␣` | `\lg`       | $\lg$           |
|     `lim␣` | `\lim`      | $\lim$          |
|  `liminf␣` | `\liminf`   | $\liminf$       |
|  `limsup␣` | `\limsup`   | $\limsup$       |
|      `ln␣` | `\ln`       | $\ln$           |
|     `log␣` | `\log`      | $\log$          |
|     `max␣` | `\max`      | $\max$          |
|     `min␣` | `\min`      | $\min$          |
|     `mod␣` | `\mod`      | $\mathrm{mod}$  |
|      `Pr␣` | `\Pr`       | $\Pr$           |
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
