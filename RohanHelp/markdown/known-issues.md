---
title: "Known Issues"
css: styles.css
---

To help you avoid frustration/outrage with unexpected issues, we've compiled a list of known issues you might experience while using Rohan. We are actively working to resolve these, but in the meantime, here are some workarounds and explanations.

## Scrolling Issues

If the cursor is **far too distant ** (say, many many pages away) from the visible
area, automatic scrolling may not bring it fully into view immediately.

This is a known issue also affecting other macOS developers. If this occurs, scroll manually to reveal the cursor position, or move the cursor left or right to bring it into view. We are investigating this issue and will fix it in a future release.

## Cursor Positioning

Rarely, a line may extrude into the right margin of the page, while the cursor remains constrained within the margin. This can happen when the cursor is positioned at the end of a line.

This is probably a bug in the underlying layout engine. This does not affect logical cursor movement, but it can be visually disorienting. We are investigating this issue and will fix it in a future release.
