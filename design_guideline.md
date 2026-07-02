# Mint — Design Guideline

## Brand Identity

- **Name:** Mint — AI Video Studio
- **Positioning:** Turn selfies into music videos with a single prompt. No editing skills needed.
- **Tone:** Clean, minimal, confident. White space is a feature, not an absence.

---

## Color System

| Token | Value | Usage |
|-------|-------|-------|
| `--bg` (surface) | `#fff` | Page backgrounds, cards, modals |
| `--surface-alt` | `#f8f8f8` | Secondary card fills, textarea backgrounds |
| `--surface-hover` | `#f5f5f5` | Button hover, chip backgrounds |
| `--border` | `#e8e8ed` | Card borders, dividers, input borders |
| `--border-light` | `#f0f0f0` | Subtle dividers, section separators |
| `--text-primary` | `#111` | Headings, body copy, primary labels |
| `--text-secondary` | `#666` | Body text, descriptions |
| `--text-tertiary` | `#888` | Secondary metadata, timestamps |
| `--text-muted` | `#999` / `#bbb` / `#ddd` | Placeholder text, disabled states, dot indicators |
| `--accent` (black) | `#111` | Buttons, toggles, selection rings, radio fills |
| `--green` | `#2e7d32` | Trial badges, savings text, success indicators |
| `--green-bg` | `#e8f5e9` | Trial badge background |
| `--gray-chip` | `#eee` | Photo cell placeholder fills (hsl-based: `hsl(hue, 18%, 92%)`) |

**Rule:** When in doubt, reach for black (`#111`) and white (`#fff`). The accent IS black. Green is the only secondary color — used sparingly for value signals (trial, savings, features).

---

## Typography

- **Font:** [Figtree](https://fonts.google.com/specimen/Figtree) (Google Font)
- **Weights used:** 400 (body), 500 (default), 600 (semibold), 700 (bold), 800 (heavy)
- **Default weight:** `500` (Medium) — set on `body`, inherited everywhere
- **Fallback stack:** `'Figtree', -apple-system, Helvetica Neue, sans-serif`

### Scale

| Element | Size | Weight | Letter-spacing | Line-height |
|---------|------|--------|----------------|-------------|
| Onboarding heading (h1) | 28px | 700 | — | 1.2 |
| Screen title | 26px | 700 | — | — |
| Section title | 20px | 700 | — | — |
| Card title | 18px | 700 | -0.3px | — |
| Plan name | 16px | 600 | — | — |
| Body | 15px | 400 | — | 1.5 |
| Body (medium) | 15px | 500 | — | 1.6 |
| Small body | 14px | 500 | — | — |
| Fine print | 13px | 500 | — | 1.4 |
| Tiny | 11px / 12px | 400 / 500 | — | — |
| Status bar | 12px | 600 | — | — |
| Pricing (large) | 22px | 700 | — | — |

---

## Spacing System

Grid base: **4px**. All spacing snaps to multiples.

| Token | px | Common use |
|-------|----|------------|
| — | 2px | Photo grid gaps, timeline segment gaps |
| — | 4px | Chip gaps, icon spacing in feature rows |
| — | 6px | Hint chip gaps, plan card gaps, dot gaps |
| — | 8px | Album chip gaps, album bar padding, button gaps |
| — | 10px | Plan card gaps |
| — | 12px | Feature item padding, selected clip gaps, fine print padding, trial row padding |
| — | 14px | Chip padding (horizontal), radio border width |
| — | 16px | Card padding, button padding, textarea padding, paywall spacing |
| — | 20px | Screen horizontal padding (standard), photo grid padding, plan card padding |
| — | 24px | Onboarding button area padding, paywall top padding, bottom bar padding |
| — | 32px | Onboarding slide padding (horizontal) |
| — | 36px | Paywall bottom padding |
| — | 40px | Paywall top padding |
| — | 48px | Paywall icon size, selected clip thumbnail |
| — | 52px | Top bar height |
| — | 60px | Onboarding carousel top padding |
| — | 72px | Onboarding emoji size |

---

## Corner Radii

| Token | Value | Use |
|-------|-------|-----|
| small | 3px | Duration badges, chip fills in timeline |
| medium | 6px | Photo cell thumbnails, selected clip thumb |
| standard | 8px | Album chips, hint chips, search bar, textarea |
| large | 12px | Selected clip card, area wraps, plan cards |
| pill | 14px | Primary buttons |
| extra | 20px | Trial badges, bottom bar input |
| full | 50% | Radio buttons, send button, notch, toggle knob |

---

## Component Specs

### Buttons

**Primary (CTA)**
- Background: `#111`
- Text: `#fff`, 17px, 600 weight
- Padding: 16px vertical, full width
- Border-radius: 14px
- Active state: `transform: scale(.97)`
- Font-family: inherit (Figtree)

**Ghost / Link**
- Background: transparent
- Text: `#999` (skip), `#888` (restore), `#111` (change)
- Underline on skip/restore links
- Font-size: 14px (skip), 12px (restore), 13px (change)

**Send (circle)**
- Width/Height: 38px
- Background: `#111`
- Text: `#fff`, 16px
- Border-radius: 50%
- Active: `transform: scale(.9)`

### Plan Cards

- Border: 1.5px `#e8e8ed`, radius 14px
- Padding: 16px
- Selected state: `border-color: #111`
- Popular variant: `border-color: #111`, `background: #fafafa`
- Popular badge: absolute positioned at top center, `-8px` offset, `#111` bg, `#fff` text, 10px, 700 weight, uppercase
- Radio: 20px circle, 2px `#ddd` border, selected shows `#111` fill
- Price: 22px 700, sub in 12px 500 `#888`

### Toggle (Free Trial)

- Width: 44px, Height: 26px, Border-radius: 13px
- Background: `#ddd` (off), `#2e7d32` (on)
- Knob: 22px circle, `#fff`, 1px 3px shadow
- Transition: `transform .2s`, `translateX(18px)` when on

### Onboarding Slides

- Hero emoji: 72px
- Heading: 28px, 700, `#111`
- Body: 16px, 400, `#666`, max-width 300px
- Feature list: left-aligned, 280px max-width
- Feature items: display flex, gap 12px, 15px 500 `#333`, bottom border `#f0f0f0`
- Check circles: 22px, `#111` bg, `#fff` checkmark, 11px
- Dots: 6px circles, `#ddd` default, 24px×6px active (`#111`), transition all .3s
- Skip button: centered, underline, `#999`, 14px

### Photo Grid Cells

- Aspect-ratio: 1:1
- Background: `hsl(hue, 18%, 92%)` — random hue per cell
- Size: 32px emoji centered
- Selection ring: 3px `#111` border on selected
- Play badge: 22px circle top-right, `#111` bg, `#fff` checkmark
- Duration badge: bottom-left, 10px 600 `#fff`, `rgba(0,0,0,.5)` bg, 1px 5px padding
- Type icon: bottom-right, 11px, opacity .5

### Prompt Screen

- Selected clip card: `#f8f8f8` bg, 1px `#e8e8ed` border, 12px radius, 10px 12px padding
- Area wrap: `#f8f8f8` bg, 12px radius, 16px padding
- Textarea: transparent bg, 15px 500, 1.6 line-height
- Bottom bar: border-top `#f0f0f0`, 8px 20px 24px padding
- Bottom input: `#f5f5f5` bg, 20px radius, 10px 14px padding

---

## Screen Flow

```
Onboarding (3 slides) → Paywall → Photo Picker → Prompt → Done
```

| # | Screen | Purpose |
|---|--------|---------|
| 0 | **Onboarding** | 3 slides showing value props: "Turn selfies into music videos", "AI-powered video magic", "Ready to create?" — each with feature checklists. Skip link available. |
| 1 | **Paywall** | Annual and Monthly Pro plans with a 3-day trial, 8 edits/day, restore purchases, and clear post-trial pricing. Designed as an "invite" not a barrier. |
| 2 | **Photo Picker** | iOS-style 3-column grid of user's photos/videos. Album filter chips. Tap to select a video. "Next" button activates on selection. |
| 3 | **Prompt** | Selected clip summary card. Full textarea for describing the desired output. 4 prompt hint chips. Bottom input bar synced with textarea. Send button triggers creation. |

---

## Design Principles

1. **White is the canvas.** Background stays `#fff` — let content breathe.
2. **Black is the accent.** Buttons, toggles, selections, rings — all `#111`.
3. **Green is for value only.** Trial badges, savings text, feature checkmarks. Never use it decoratively.
4. **One font, one weight.** Figtree 500 everywhere for body. 700 for headings. No mixing font families.
5. **No music, no effects, no steps.** The flow is: pick a video → write a prompt → done. Everything else is noise.
6. **Paywall as invite, not barrier.** Show the value first (onboarding). Free trial toggle is on by default. "Maybe later" is always visible. The price feels like a detail, not a gate.
7. **Radii are generous** (14px buttons, 12px cards) but never playful. It's clean, not cute.
