# Definition

## Document

A **generic document** is a sequence of bytes.

A **document of a specific type** is one that conforms to the format
requirements of that document type.

A **document type** is defined as the set of all documents that satisfy
its format requirements.

A **document format** refers to a set of consistent rules governing the structure of
a document within a specific document type.

[????]
Formally, the set of such rules can be stated as ... 
[???]

A **document file** is a regular computer file whose byte sequence can be
deserialized into a document.

## User

A **user** is a reasonably sensible human.

## Editor

A **editor** is a program that can read a document file,
change a document from one state to another.

# GUI

* menu bar
* document window (0...)
    * document view
    * horizontal scroll bar (0...1)
    * vertical scroll bar (0...1)

## Menu bar

* Rohan
    * About Rohan
    * \------------------------
    * Settings...
    * \------------------------
    * Services
    * \------------------------
    * Hide Rohan
    * Hide Others
    * Show All
    * \------------------------
    * Quit Rohan

* File
    * <details>
      <summary>New</summary>
      Create a new document with no backend file, with a name distinct from all open documents with no backend file.
      </details>
    * \------------------------
    * Save
    * Save As...
    * \------------------------
    * Close

* Edit
    * <details>
      <summary>Undo &lt;action name&gt;</summary> 
      When there is no last action, show inactive "Undo".<br>
      When there is last action, say "paste", show "Undo Paste".
      </details>
    * <details>
      <summary>Redo &lt;action name&gt;</summary>
      When there is no last undo action, show inactive "Redo".<br>
      When there is last undo action, say "Undo Paste", show "Redo Paste".
      </details>

// What do we mean by "action"

* Help
    * &lt;search bar&gt;
    * Help

## Scroll bar

* Vertical scroll bar
    * **isActive.** It becomes active when document layout **height** outsize the
      viewport height.
    * **isVisible.** It becomes visible when `isActive` is true and the mouse
      cursor moves into the bar area.
* Horizontal scroll bar
    * **isActive.** It becomes active when document layout **width** outsize the
      viewport width.
    * **isVisible.** It becomes visible when `isActive` is true and the mouse
      cursor moves into the bar area.
