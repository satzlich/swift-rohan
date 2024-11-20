
[Quick Start](https://facebook.github.io/lexical-ios/documentation/lexical/quickstart)

## Overview

- For graphic interaction, use `LexicalView`.
- For accessing data model only, use `Editor`.
    - Headless Editor is what you need.

## Creating a LexicalView

- Customization of `LexicalView`.
  - Add plugins;
  - Set up the theme.

## Working with Editor States

The example illustrates a way to extract, serialize, and set the editor state.

## Update an editor

Ways to change the current state of editor:

- Update the editor state
  - `Editor.update(_:)`
- Set the editor state
  - `Editor.setEditorState(_:)`
- Set up node transforms
  - `Editor.addNodeTransform(...)`
- Set up command listeners
  - `Editor.registerCommand(...)`

**Note.** 
The methods of the first two bullets immediately change the editor state when used.
The methods of the last two bullets affects how an update/command will behave in the future.

The example illustrates how to obtain the document tree and the selection, and also simple manipulation of the document tree.

## User input and update listeners

Update listeners allow the user to be informed of and react to updates.

One can set up such update listeners with `Editor.registerUpdateListener(...)`.