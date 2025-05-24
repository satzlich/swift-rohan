
# Replacement Rules

Replacement rules are used to convert the text entered by the user into another format.

## Text Mode Rules (12)

The following rules are applied when the cursor is in text area:

| Pattern          | Replacement              | Space |
| :--------------- | :----------------------- | :---- |
| `(backquote)     | $‘$ (left single quote)  |       |
| ``               | $“$ (left double quote)  |       |
| ' (single quote) | $’$ (right single quote) |       |
| ''               | $”$ (right double quote) |       |
| --               | – (en dash)              |       |
| ---              | — (em dash)              |       |
| ...              | … (ellipsis)             |       |
| #                | h1                       | ✅     |
| ##               | h2                       | ✅     |
| ###              | h3                       | ✅     |
| *                | *emph*                   | ✅     |
| **               | **strong**               | ✅     |


## Math Mode Rules

The following rules are applied when the cursor is in math area:


** Basic (6) **


| Pattern | Replacement        |
| :------ | :----------------- |
| $       | inline math        |
| ^       | attach superscript |
| _       | attach subscript   |
| '       | ′ (prime)          |
| ''      | ″ (double prime)   |
| '''     | ‴ (triple prime)   |


** Miscellaneous (3) **

| Pattern | Replacement | Space |
| :------ | :---------- | :---- |
| ...     | \ldots      |       |
| oo      | \infty      | ✅     |
| xx      | \times      | ✅     |

** Inequalities (3) **

| Pattern | Replacement |
| :------ | :---------- |
| !=      | \neq        |
| <=      | \leq        |
| >=      | \geq        |

** Arrows (5) **

| Pattern | Replacement     |
| :------ | :-------------- |
| <-      | \leftarrow      |
| ->      | \rightarrow     |
| =>      | \Rightarrow     |
| -->     | \longrightarrow |
| ==>     | \Longrightarrow |


** Left-right delimiters (7) **

| Pattern | Replacement                |
| :------ | :------------------------- |
| ()      | \left( \right)             |
| []      | \left[ \right]             |
| {}      | \left\{ \right\}           |
| [)      | \left[ \right)             |
| (]      | \left( \right]             |
| <>      | \left\langle \right\rangle |
| \| \|   | \left\lceil \right\rceil   |



** Set operations (5) **

| Pattern | Replacement | Space | Note                |
| :------ | :---------- | :---- | ------------------- |
| cap     | \cap        | ✅     |                     |
| cup     | \cup        | ✅     |                     |
| in      | \in         | ✅     |                     |
| sub     | \subset     | ✅     | `sup` is for $\sup$ |
| sube    | \subseteq   | ✅     |                     |

** Sum-like operators (4) **

| Pattern | Replacement | Space |
| :------ | :---------- | :---- |
| sum     | \sum        | ✅     |
| prod    | \prod       | ✅     |
| int     | \int        | ✅     |
| oint    | \oint       | ✅     |

** Greek letters (17) **

Greek letters whose names is of length 4 or less. 

| Pattern | Replacement | Space |
| :------ | :---------- | :---- |
| beta    | \beta       | ✅     |
| chi     | \chi        | ✅     |
| eta     | \eta        | ✅     |
| iota    | \iota       | ✅     |
| mu      | \mu         | ✅     |
| nu      | \nu         | ✅     |
| phi     | \phi        | ✅     |
| pi      | \pi         | ✅     |
| psi     | \psi        | ✅     |
| rho     | \rho        | ✅     |
| tau     | \tau        | ✅     |
| xi      | \xi         | ✅     |
| zeta    | \zeta       | ✅     |
| Pi      | \Pi         | ✅     |
| Phi     | \Phi        | ✅     |
| Psi     | \Psi        | ✅     |
| Xi      | \Xi         | ✅     |


** Styled Letters (234) **

| Pattern | Replacement  | Space |
| :------ | :----------- | :---- |
| bbA     | \mathbf{A}   | ✅     |
| ...     |              | ✅     |
| bbZ     | \mathbf{Z}   | ✅     |
| bba     | \mathbf{a}   | ✅     |
| ...     |              | ✅     |
| bbz     | \mathbf{z}   | ✅     |
| bbbA    | \mathbb{A}   | ✅     |
| ...     |              | ✅     |
| bbbZ    | \mathbb{Z}   | ✅     |
| ccA     | \mathcal{A}  | ✅     |
| ...     |              | ✅     |
| ccZ     | \mathcal{Z}  | ✅     |
| frA     | \mathfrak{A} | ✅     |
| ...     |              | ✅     |
| frZ     | \mathfrak{Z} | ✅     |
| sfA     | \mathsf{A}   | ✅     |
| ...     |              | ✅     |
| sfZ     | \mathsf{Z}   | ✅     |
| sfa     | \mathsf{a}   | ✅     |
| ...     |              | ✅     |
| sfz     | \mathsf{z}   | ✅     |
| ttA     | \mathtt{A}   | ✅     |
| ...     |              | ✅     |
| ttZ     | \mathtt{Z}   | ✅     |
| tta     | \mathtt{a}   | ✅     |
| ...     |              | ✅     |
| ttz     | \mathtt{z}   | ✅     |


** Math Operators (44) **

| Pattern | Replacement | Space |
| :------ | :---------- | :---- |
| arccos  | \arccos     | ✅     |
| arcsin  | \arcsin     | ✅     |
| arctan  | \arctan     | ✅     |
| arg     | \arg        | ✅     |
| cos     | \cos        | ✅     |
| cosh    | \cosh       | ✅     |
| cot     | \cot        | ✅     |
| coth    | \coth       | ✅     |
| csc     | \csc        | ✅     |
| csch    | \csch       | ✅     |
| ctg     | \ctg        | ✅     |
| deg     | \deg        | ✅     |
| det     | \det        | ✅     |
| dim     | \dim        | ✅     |
| exp     | \exp        | ✅     |
| gcd     | \gcd        | ✅     |
| hom     | \hom        | ✅     |
| id      | \id         | ✅     |
| im      | \im         | ✅     |
| inf     | \inf        | ✅     |
| injlim  | \injlim     | ✅     |
| lcm     | \lcm        | ✅     |
| projlim | \projlim    | ✅     |
| ker     | \ker        | ✅     |
| lg      | \lg         | ✅     |
| lim     | \lim        | ✅     |
| liminf  | \liminf     | ✅     |
| limsup  | \limsup     | ✅     |
| ln      | \ln         | ✅     |
| log     | \log        | ✅     |
| max     | \max        | ✅     |
| min     | \min        | ✅     |
| mod     | \mod        | ✅     |
| Pr      | \Pr         | ✅     |
| sec     | \sec        | ✅     |
| sech    | \sech       | ✅     |
| sin     | \sin        | ✅     |
| sinc    | \sinc       | ✅     |
| sinh    | \sinh       | ✅     |
| sup     | \sup        | ✅     |
| tan     | \tan        | ✅     |
| tanh    | \tanh       | ✅     |
| tg      | \tg         | ✅     |
| tr      | \tr         | ✅     |

## Stability of Replacement Rules

The replacement rules are stable in the sense that they are not expected to change frequently.
However, they can be updated as needed to improve the overall editing experience.
