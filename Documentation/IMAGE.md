#  Image

* imag format: jpg/jpeg, pdf, png, svg, tiff
* image alignment: inheirted from parent node.
* image size: if image width is greater than content width, it is scaled down to fit the content width. Otherwise, it is displayed at its original size.

**strategy for referencing images** in a document: 
(1) images are base64-encoded and embedded in the document, and
(2) images are stored in a subdirectory named "images" relative to the document's fileURL.

## Process

When an image command is triggered:

1. If the current cursor position does not allow for image insertion, return an error message "OperationRejected".
2. If the current cursor position allows for image insertion, proceed with the following steps:
3. Display a dialog to select an image file.
4. If the user selects a file, insert the image into the document.
5. If the user cancels, do nothing.


When the user selects a file, an absolute path to the image file is obtained.

1. If the document does not have fileURL, prompt the user to save the document first.
2. Now the document must have fileURL, obtain the directory of the document.
3. Create a subdirectory named "images" in the document directory if it does not exist.
4. Copy the selected image file to the "images" subdirectory if it does not already exist there.
5. Insert an image node into the document with the relative path to the copied image file.
