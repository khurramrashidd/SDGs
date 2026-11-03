# Logo, icons and responsive UI

---

## The mark

An open ring with an amber dot rising out of its gap.

The ring is the shared goal; the dot is a seed that leaves it and grows —
**from beginning to impact**. In the full mark (`brand/logo_mark.svg`) the dot
becomes three, growing as they rise: beginning, momentum, impact.

**This is deliberately not the UN SDG colour wheel.** That wheel is an official
United Nations emblem with its own usage rules — not ours to redraw. The 17
goals are carried by the app's content and the per-tile SDG accent colours, not
by imitating a UN logo. That matters for Play Store review as well as honesty.

### The files

| File | Use |
|---|---|
| `brand/logo_mark.svg` | Full mark, ring + 3 dots. Headers, print, the website. |
| `brand/logo_mark_small.svg` | Simplified, ring + 1 dot. Anywhere under ~64px. |
| `brand/icon_badge.svg` | **App icon / favicon.** White mark on a teal rounded square. |
| `brand/icon_badge_square.svg` | Same, square corners. For maskable PWA icons. |
| `brand/icon_foreground.svg` | Android adaptive-icon foreground layer. |

Three variants exist because one drawing cannot do every job. The detailed mark
turns to mush at 16px, and the bare mark vanishes on a dark browser tab. The
badge solves both: it stays legible down to 16px on any background.

The in-app logo (top-left of the home screen) is **drawn in code**, not loaded
from a file — `_LogoPainter` in `lib/features/home/home_page.dart`. It picks up
the user's chosen accent colour and stays sharp at any size, with no extra
package and no asset to ship.

---

## Installing the icons

From the project root, once:

```
install_icons.bat
```

```
flutter clean
flutter run
```

It copies Android launcher icons (all five densities, legacy plus adaptive),
web favicons, the PWA manifest and the branded `index.html` into the folders
`flutter create` generated. Safe to re-run.

### What it installs

**Android** — legacy `ic_launcher.png` at 48/72/96/144/192, plus a proper
adaptive icon (`ic_launcher_foreground` + a teal background colour) so the
launcher can mask it into a circle, squircle or teardrop without clipping the
mark. The foreground keeps all content inside the centre 60% for exactly that
reason. A `monochrome` layer is declared too, so Android 13+ themed icons work.

**Web** — `favicon.ico` (16/32/48 in one file), `apple-touch-icon.png`, PWA
icons at 192 and 512 in both `any` and `maskable` purposes, and a
`manifest.json` that makes the app installable to a phone home screen.

**Boot screen** — `web_template/index.html` replaces Flutter's blank white
loading page with the mark on the brand background, ring spinning, dot fixed.
It respects `prefers-color-scheme` and `prefers-reduced-motion`, and brightens
the teal on dark backgrounds where the deep brand teal loses contrast.

---

## Responsive UI

Everything goes through `lib/core/layout/responsive.dart` rather than scattered
`MediaQuery` checks.

### Breakpoints

| Name | Width | Device |
|---|---|---|
| `compact` | < 360dp | Budget and older Android phones |
| `regular` | 360–599dp | Ordinary phones — the common case |
| `medium` | 600–904dp | Large phones landscape, small tablets |
| `expanded` | ≥ 905dp | Tablets, desktop browsers |

### What adapts

**Page padding** — 12 / 16 / 24 / 32dp. A 320dp phone cannot afford to lose
40dp of width to margins.

**The home grid** — `AdaptiveGrid` works out its column count from the
available width, so the same code gives 2 columns on a small phone and 5 on a
desktop browser. There is no second layout to keep in sync. Tile padding, icon
sizes and font sizes step down on `compact`.

**Content width** — `ContentShell` caps page content at 840dp (narrower for
forms) and centres it. Without this, a scheme list on a 1920px browser window
stretches into unreadable full-width lines.

**The theme chooser** — a three-segment control on normal phones, stacked
tiles on `compact`, where three labelled segments would truncate.

### Text scaling

The user's chosen text size is applied globally in `main.dart`, not per widget.
Four steps up to 1.35×. This is an accessibility need for the intended
audience, not a nicety, so every screen was built to reflow rather than clip —
tiles use `maxLines` with ellipsis, and nothing is pinned to a fixed height
that large text would overflow.

---

## Radios were replaced

`RadioListTile` is gone, in favour of `SelectionTile`
(`lib/core/widgets/selection_tile.dart`).

Two reasons:

1. Flutter deprecated `Radio.groupValue` and `Radio.onChanged` in favour of a
   `RadioGroup` ancestor. Using either form pins the app to a Flutter version
   range — the deprecation warnings in your build came from exactly this.
   `SelectionTile` works on every version.
2. The whole row is the tap target instead of a 20dp circle. For people on
   small phones who are not confident with touchscreens, that is the point.

---

## Changing the colours

`lib/core/theme/brand.dart` — four hex codes at the top. Change them and every
screen, button, tile and dialog follows.

The icons do **not** follow automatically, because they are rasterised PNGs.
After changing the palette, edit the matching hex values in the five
`brand/*.svg` files and re-export. The current values are:

- Primary teal `#0E6E6E`
- Secondary teal `#14919B`
- Accent amber `#F2A93B`
- Ink `#14231F`

These are my proposal, not your brand — I was not able to reach ibtidaatech.com
from this environment to sample the real palette. Send the hex codes or a
screenshot and I will regenerate every icon to match.
