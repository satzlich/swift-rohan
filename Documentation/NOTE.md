
# NOTE

**Mismatch** between DocumentManager and natural text editing behaviour

- When performing insertion of text, the range may occasionally not match the 
  extent of the text but rather the paragraph that holds it. Taking the end 
  location of the range will yield an unexpected insertion point. 
  Even worse, insertion at that insertion point may result in more paragraphs 
  being created rather than just continuing from the end of the text.
  
- Such behaviour makes undo/redo operations simpler, as the range can be used to
  remove the entire paragraph instead of just the inline content.
