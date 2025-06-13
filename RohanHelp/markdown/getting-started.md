---
title: "Getting Started with Rohan"
css: styles.css
---

## Commands and Code Snippets

Press `Esc`, backslash (`\`) or `Ctrl+Space` to trigger a compositor window, and type mnemonics
to insert commands or code snippets into your document. For details on available commands and 
code snippets, refer to the [Commands](commands.html) and [Code Snippets](code-snippets.html) 
section respectively.


![](images/compositor_window.png){width=75%}


## Smart Replacements

The app automatically replaces shortcuts with their intended elements as you type.
Here are some common replacements:

| Shortcut | Replacement                | Look          |
| -------- | -------------------------- | ------------- |
| `...`    | `…` (ellipsis or `\ldots`) | …             |
| `->`     | `\rightarrow` (math mode)  | $\rightarrow$ |
| `bbbR␣`  | `\mathbb{R}` (math mode)   | $\mathbb{R}$  |

For details on all replacements, refer to the [Replacement Rules](replacement-rules.html) section.

## Context Menu

Right-clicking in the document opens a context menu with options to edit the current element.
For attachments, matrices, radicals, and other elements, you can access options additional to
the standard text editing options.

![](images/context_menu.png){width=75%}

## MultiLingual Support

- In math mode, use `\text{}` to insert text in the current language.
- Right-to-left scripts (e.g., Arabic) are planned for future support.

## Exporting

To export your document to LaTeX source code, use the `Export` menu item under the `File` menu.
This will generate a `.tex` file that you can compile with XeLaTeX.

## Discrepancies with LaTeX

The app supports a subset of LaTeX commands, particularly those related to math mode.
While similar, some discrepancies exist. For details on these differences, refer to
the [Discrepancies](discrepancy.html) section.

## Known Issues

For a list of known issues and workarounds, refer to the [Known Issues](known-issues.html) section.
