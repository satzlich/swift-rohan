// Copyright 2024 Lie Yan

struct Link {
    public let text: String
    public let url: String

    init?(_ url: String) {
        self.init(url, url)
    }

    init?(_ text: String, _ url: String) {
        guard Link.validateText(text), Link.validateUrl(url) else {
            return nil
        }
        self.text = text
        self.url = url
    }

    static func validateText(_ string: String) -> Bool {
        return !string.isEmpty
    }

    static func validateUrl(_ string: String) -> Bool {
        // TODO: implement
        return !string.isEmpty
    }
}
