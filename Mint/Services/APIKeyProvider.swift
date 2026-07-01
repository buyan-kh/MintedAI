import Foundation

struct APIKeyProvider {
    private let infoDictionary: [String: Any]

    init(infoDictionary: [String: Any] = Bundle.main.infoDictionary ?? [:]) {
        self.infoDictionary = infoDictionary
    }

    func geminiAPIKey() -> String {
        guard let value = infoDictionary["GEMINI_API_KEY"] as? String else { return "" }
        let key = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard key != "$(GEMINI_API_KEY)" else { return "" }
        return key
    }
}
