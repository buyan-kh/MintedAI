import Foundation

@MainActor
struct AppContainer {
    let editSessionViewModel: EditSessionViewModel

    static func live() -> AppContainer {
        let apiKey = APIKeyProvider().geminiAPIKey()
        let client = GeminiClient(apiKey: apiKey)
        return AppContainer(
            editSessionViewModel: EditSessionViewModel(
                fileService: GeminiFileService(client: client),
                omniService: OmniInteractionService(client: client),
                store: VideoEditSessionStore()
            )
        )
    }
}
