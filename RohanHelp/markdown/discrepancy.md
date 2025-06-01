# Discrepancy

Discrepancies exist between the app's LaTeX support and standard LaTeX commands, particularly in math mode. Here are some key differences:

## Prime Marks (')

For simple formulas like `x'` and `x\prime`, there are natural counterparts in the app.
For formulas that mix primes and super-/sub-scripts like `x''^m` and `x''_n`, there are no natural counterparts.
Use `x^{''m}` and `x^{''}_n` instead.

## Limits

The app does not support `\limits` and `\nolimits` in the same way as LaTeX. In LaTeX, the two commands are 
used as postfix to operators like `\sum` and `\int`; but in the app, these commands wrap the operators. 

When exporting to LaTeX, the app will place `\limits` and `\nolimits` in the correct position.
