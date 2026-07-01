# Mint Omni-First iOS Design

## Goal

Build the first native iOS version of Mint as a SwiftUI app centered on Gemini Omni stateful video editing: choose one local video, describe the desired edit, generate a high-quality result, then continue refining the same video through follow-up prompts.

## Sources

- Local UI source: `mint-video-app.html`
- Local style source: `design_guideline.md`
- Gemini source: https://ai.google.dev/gemini-api/docs/omni

## Product Scope

The first build implements the real creation loop, not a decorative manual editor. The app starts with the HTML design language, then narrows the experience to the path that proves the product:

1. Onboarding introduces Mint as an AI video studio.
2. Paywall appears as an invite with a visible "Maybe later" path.
3. Home shows recent generated videos and a primary create action.
4. Video picker imports one local video from Photos or Files.
5. Prompt screen previews the selected video and captures the edit request.
6. Processing screen reports upload, file processing, generation, download, and save states.
7. Result screen plays the edited video and allows follow-up edits in the same session.

Non-goals for this build: real App Store subscriptions, account sync, social integrations, manual multi-track editing, local timeline tools, and production analytics.

## UX Direction

Mint should feel clean, direct, and premium. White is the canvas, black is the accent, and green appears only for success or value signals. The app uses the spacing, radii, typography scale, and control behavior from `design_guideline.md`. Pixel perfection is a product requirement: SwiftUI screens must be checked against the HTML proportions, spacing, and hierarchy on simulator screenshots before the UI is accepted.

The HTML's dark timeline editor is not part of the first functional build. Its "stateful editing" idea is reinterpreted as conversational Omni editing: each result can receive another prompt while preserving the previous generated video state.

## Core Flow

### First Edit

1. User selects a video.
2. App stores a security-scoped local copy in the app documents directory.
3. User enters a prompt.
4. App uploads the video to Gemini Files API.
5. App polls the file until it is active or failed.
6. App creates an Omni interaction with:
   - `model`: `gemini-omni-flash-preview`
   - input document URI from the uploaded file
   - prompt text
   - `generation_config.video_config.task`: `edit`
   - `response_format`: `{ "type": "video", "delivery": "uri" }`
7. App polls/downloads the generated video URI when needed.
8. App saves the result locally and records the interaction id.

### Follow-Up Edit

1. User enters a follow-up prompt from the result screen.
2. App sends a new interaction with:
   - `model`: `gemini-omni-flash-preview`
   - `previous_interaction_id`: last successful interaction id
   - prompt text
   - `response_format`: `{ "type": "video", "delivery": "uri" }`
3. App downloads and stores the new result.
4. Session history shows original prompt and follow-up prompts.

## API Design

Use a native Swift REST client rather than a Python or JavaScript sidecar.

Main units:

- `GeminiClient`: owns authenticated REST calls, request construction, response decoding, retry policy, and typed errors.
- `GeminiFileService`: uploads videos, checks file state, and downloads generated files.
- `OmniInteractionService`: creates first-turn edit interactions and follow-up stateful interactions.
- `VideoEditSessionStore`: persists local video URLs, prompt history, generated output URLs, Gemini file names, and interaction ids.
- `VideoImportService`: copies imported assets into app storage and validates file type, duration, and size.

Authentication uses a local development API key stored outside git, loaded from an ignored config file or Xcode environment setting. This first local build calls Gemini directly from the app for development. Before TestFlight or App Store distribution, move the key behind a backend proxy.

## State Model

`VideoEditSession`:

- `id`: local UUID
- `sourceVideoURL`: local app file URL
- `sourceFileName`: Gemini file name after upload
- `sourceFileURI`: Gemini file URI after processing
- `turns`: ordered edit turns
- `createdAt`, `updatedAt`

`VideoEditTurn`:

- `id`: local UUID
- `prompt`: user text
- `interactionID`: Gemini interaction id
- `previousInteractionID`: nil for the first successful turn, otherwise the prior Gemini interaction id
- `outputVideoURL`: local app file URL
- `remoteOutputURI`: Gemini output URI when provided
- `status`: queued, uploading, processingInput, generating, downloading, completed, failed
- `errorMessage`: user-readable failure text when failed

## Error Handling

The UI should keep the user oriented with specific, recoverable messages:

- Missing API key: show a setup error and disable generation.
- Upload failure: allow retry without reselecting the video.
- File processing failure: explain that Gemini could not process the source video.
- Safety or policy block: show a neutral message and let the user edit the prompt.
- Generation failure: allow retry with the same prompt.
- Download failure: allow retry download when the interaction completed but the file did not save locally.
- Region limitation for uploaded video editing: show that uploaded video editing is unavailable for the current region.

No raw JSON or API keys appear in UI errors.

## Quality Requirements

- Request URI delivery for generated videos to avoid inline base64 limits on larger outputs.
- Keep `store` enabled for turns that need follow-up stateful edits.
- Use simple edit prompts and append "Keep everything else the same." for hint chips that target a specific change.
- Save outputs as `.mp4` in app storage and expose system share/save actions from the result screen.
- Do not claim 4K unless the API response and saved file metadata support it. The UI can say "high quality" until the implementation verifies actual dimensions.

## Screens

### Onboarding

Three slides based on the HTML, but copy should emphasize AI video editing and stateful follow-up prompts rather than manual timeline editing.

### Paywall Invite

Use the existing annual/monthly/lifetime visual structure as a non-blocking invite. "Maybe later" opens Home. Real purchases are deferred.

### Home

Show Mint title, recent sessions, empty state, and one primary create button. Gallery cards use local generated outputs once available.

### Video Picker

Use PhotosPicker for the common path and a Files import fallback if needed. Accept one video at a time.

### Prompt

Show selected video preview, prompt text area, character count, concise hint chips, and a black circular send button. Disable send until a non-empty prompt and valid video are present.

### Processing

Report real stages from app state: importing, uploading, processing video, generating edit, downloading result, saving. Progress can be indeterminate when Gemini does not provide exact progress.

### Result

Play the generated video, show prompt history, support follow-up prompt entry, share sheet, save-to-Photos action, and return Home.

## Testing Strategy

- Unit test request builders for first edit and follow-up edit payloads.
- Unit test response decoding for inline video data, URI output, file states, and API errors.
- Unit test session persistence for multiple turns.
- UI test the happy path with a mock Gemini client: import fixture video, enter prompt, complete mocked generation, show result, submit follow-up prompt.
- Manual simulator check: screen layout, keyboard behavior, video preview sizing, empty states, and error surfaces.
- Visual review simulator screenshots against `mint-video-app.html` and `design_guideline.md` for spacing, typography scale, radii, color, and button states.

## Acceptance Criteria

- A SwiftUI Xcode project exists and builds.
- The app follows the approved Mint visual system from the HTML and guideline.
- Core screens pass a simulator screenshot review for pixel-level spacing, hierarchy, and control polish.
- A user can import one video, enter an edit prompt, and start generation.
- The Gemini integration supports uploaded video editing through Files API and Interactions API.
- Successful generations store interaction ids and allow follow-up prompts with `previous_interaction_id`.
- High-quality output retrieval uses URI delivery when available.
- Generated videos are saved locally and playable in the app.
- Errors are understandable and recoverable.
- Tests cover API payload construction, decoding, persistence, and the mocked edit flow.
