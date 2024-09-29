// Copyright 2024 Lie Yan

public struct Document {
    private(set) var selection: Selection?

    /**
     True if selected to receive input from the user by an event;
     false, otherwise.

     - Note: The state of `isFocused == false` is called **blurred**.
     */
    public private(set) var isFocused: Bool
}
