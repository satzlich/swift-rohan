---
title: "Known Issues"
css: styles.css
---

To help you avoid frustration/outrage with unexpected issues, we've compiled a list of known issues you might experience while using Rohan. We are actively working to resolve these, but in the meantime, here are some workarounds and explanations.

## Scrolling Issues

If the cursor is too distant (e.g., many pages away) from the visible area, automatic scrolling may not bring it fully into view immediately.

This is a known issue affecting other macOS developers as well. If this occurs:

- Scroll manually to reveal the cursor position, or
- Move the cursor left or right to bring it into view.

We're investigating this issue and will address it in a future release.

## Cursor Positioning

In rare cases, a line may extend slightly beyond the right margin (by half a character or more), while the cursor remains constrained within the margin. This typically happens when the cursor is positioned at the end of a line.

This appears to be a bug in the underlying layout engine. While it doesn’t affect logical cursor movement, it can be visually disorienting. We're investigating and will fix this in a future update.

## Unpickable Area Near Document Bottom

In some cases, particularly after magnification, the area near the bottom of whole document may not be pickable, meaning you can't select text or interact with elements in that region.

This is a known issue that can occur after zooming in or out. If you encounter this:

- Select any options of the `Theme` menu to refresh the layout.

## `{itemize}` and `{enumerate}` Lists

The layout of lists using `{itemize}` and `{enumerate}` are not yet fully supported. This means that:

- The indentation of second and subsequent lines in a list item doesn't match the first line.
- The numbering of list items may not align correctly.

Current situation is due to the limitations of the underlying layout engine, which is able to present the
desired layout from scratch but cannot maintain the appearance consistently when the document is edited or reformatted.
So we fallback to a simpler layout that does not preserve the intended formatting.

We are aware of this limitation and are working on a solution to ensure proper list formatting in future releases.
