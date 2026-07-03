# Gemini Omni Flash – Editing Uploaded Videos

## Correct API Flow

### 1. Upload video file (resumable upload)

```bash
# Start the upload
UPLOAD_URL=$(curl -s -D - -o /dev/null \
  -X POST \
  -H "X-Goog-Upload-Protocol: resumable" \
  -H "X-Goog-Upload-Command: start" \
  -H "X-Goog-Upload-Header-Content-Length: $(stat -f%z "$VIDEO_PATH")" \
  -H "X-Goog-Upload-Header-Content-Type: video/mp4" \
  -H "Content-Type: application/json" \
  -d '{"file": {"display_name": "'"$(basename "$VIDEO_PATH")"'"}}' \
  "https://generativelanguage.googleapis.com/upload/v1beta/files?key=${API_KEY}" \
  2>&1 | grep -i "x-goog-upload-url:" | sed 's/.*: //' | tr -d '\r')

# Upload bytes + finalize
curl -s -X POST \
  -H "Content-Length: $(stat -f%z "$VIDEO_PATH")" \
  -H "X-Goog-Upload-Offset: 0" \
  -H "X-Goog-Upload-Command: upload, finalize" \
  --data-binary @"$VIDEO_PATH" \
  "${UPLOAD_URL}"
```

Returns: `{"file": {"name": "files/...", "uri": "https://...", "state": "PROCESSING"}}`

### 2. Poll until ACTIVE

```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/files/${FILE_NAME}?key=${API_KEY}"
```

Poll every 5 seconds until `state` is `"ACTIVE"` (or `"FAILED"`).

### 3. Create the interaction (edit)

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/interactions?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-omni-flash-preview",
    "input": [
      {"type": "document", "uri": "https://generativelanguage.googleapis.com/v1beta/files/'"${FILE_NAME}"'"},
      {"type": "text", "text": "Describe the edit you want here"}
    ],
    "response_format": {"type": "video", "delivery": "uri"}
  }'
```

Returns an interaction with output video URI.

### 4. Poll output video until ACTIVE

```bash
curl -s "https://generativelanguage.googleapis.com/v1beta/files/${OUTPUT_FILE_ID}?key=${API_KEY}"
```

### 5. Download result

```bash
curl -s -o output.mp4 \
  "https://generativelanguage.googleapis.com/v1beta/files/${OUTPUT_FILE_ID}:download?alt=media&key=${API_KEY}"
```

---

## Critical Lessons

| Mistake | Consequence |
|---------|-------------|
| Including `generation_config` with `video_config.task: "edit"` | Causes **"Exactly one input video required"** error. The model infers the task from the input types — no need to specify it for editing. |
| Sending invalid/failed requests | They **still burn quota**. Free tier quota is very limited for Omni video. Always validate your JSON format locally before sending. |
| Forgetting `response_format` | For videos >4MB, the response may be truncated. Always set `delivery: "uri"` for production use. |

### Correct request structure (minimal):

```json
{
  "model": "gemini-omni-flash-preview",
  "input": [
    {"type": "document", "uri": "https://generativelanguage.googleapis.com/v1beta/files/{file_name}"},
    {"type": "text", "text": "Your edit prompt here"}
  ],
  "response_format": {
    "type": "video",
    "delivery": "uri"
  }
}
```

No `generation_config`. No `task` field. The document input tells the API it's a video edit.

---

## Pricing (as of July 2026)

| | Free Tier | Paid Tier (per 1M tokens) |
|---|---|---|
| Input | Not available | $1.50 (text/image/video/audio) |
| Output (text) | Not available | $9.00 |
| Output (video) | Not available | $17.50 |

---

## Notes

- File expires in **2 days** from upload
- Use `previous_interaction_id` for stateful multi-turn editing (follow-up edits without re-uploading)
- The API key in `Secrets.xcconfig` is a free tier key with limited Omni quota
- For stateful editing: first call uses `input: [document, text]`, follow-up calls use `input: [text]` with `previous_interaction_id` set
