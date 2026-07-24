# Plan: Adopting Kaakao Components in Pari

Goal: pari uses [Kaakao](https://github.com/veskuh/Kaakao) components and constants where
feasible, and keeps its own custom components only where Kaakao has no equivalent.
The plan is stepwise; every step is testable before moving on.

## Coordination

- **Coordinator:** OpenClaw (manages PLAN.md, tracks progress, orchestrates rounds)
- **Reviewer:** OpenCode CLI
- **Implementer/Fixer:** agy (Antigravity CLI)
- **Workflow:** OpenCode reviews → agy implements/fixes → agy commits → verify → next step
- **Build:** cmake --build build -- -j1 (single-thread, long timeouts)
- **Status tracking:** Updated after each round below

## Agreed decisions

- **Vendoring:** Kaakao is added as a git submodule at `third-party/Kaakao`, built via `add_subdirectory()`.
- **Visual end state:** Adopt the Kaakao (macOS Yosemite–Catalina) look. Where a Kaakao component
  exists, it is used as-is; pari's Atelier styling survives only in custom parts (editor well, diff bench).
- **Theme strategy:** `PariTheme` remains as a thin facade over Kaakao's `Theme` singleton. It keeps
  its current property names (no churn at ~30 call sites and all test fallbacks) but sources shared
  constants from `Theme`. Pari-specific constants stay in `PariTheme`.
- **Tests:** UI tests of components that are fully replaced by Kaakao equivalents are deleted
  (Kaakao has its own test suite). Tests for pari-specific logic are kept.

## Key technical facts

- Pari loads QML from `qrc:/qml/...` with legacy `qmldir` modules; `PariTheme` is a plain QML object
  instantiated in `PariAppWindow` and resolved via dynamic scope, with a local fallback instance in
  every component/test (`typeof pariTheme !== 'undefined'` pattern).
- Kaakao is a proper QML module (`qt_add_qml_module`, URI `Kaakao`, resource prefix `/qt/qml`) with a
  `Theme` singleton (`themeMode`: System/Light/Dark) and ~45 components.
- Kaakao's root `CMakeLists.txt` unconditionally builds gallery + tests, so pari adds only its
  `src/` subdirectory. Kaakao's `src/CMakeLists.txt` has no own `find_package`; pari's must cover it.
- New dependency: `Qt5Compat.GraphicalEffects` (CMake packages `Core5Compat`, `ShaderTools`).
- Pari drives `Theme.themeMode` from `appSettings.systemThemeIsDark`.

### Verification commands (used by every step)

```bash
cmake -B build && cmake --build build
./build/tests/tst_all
./build/tests/tst_ui -input tests/
./build/src/pari --selfcheck        # macOS: ./build/src/pari.app/Contents/MacOS/pari --selfcheck
```

## End-state component disposition

### Replaced by Kaakao (pari versions deleted, with their UI tests)

| Pari / stock control | Kaakao replacement |
|---|---|
| `PariButton` | `KaakaoButton` |
| `PariToolButton`, `PariIconButton` | `KaakaoToolButton` |
| `PariTabBar` (document tabs) | `KaakaoTabBar` / `KaakaoTabButton` |
| `PariSidebarTabBar` (sidebar strip) | `KaakaoSegmentedControl` |
| `PariReadOnlyTextArea` | `KaakaoTextArea` (readOnly) |
| Stock `TextField` usage sites | `KaakaoTextField` |
| Search inputs (`GlobalSearchPane`, `FindOverlay`) | `KaakaoSearchField` |
| Stock `CheckBox` | `KaakaoCheckBox` |
| Stock `ComboBox` | `KaakaoComboBox` |
| Stock `ProgressBar` | `KaakaoProgressBar` |
| Stock `BusyIndicator` (`AiThinkingIndicator`) | `KaakaoBusyIndicator` |
| Stock `Dialog` (`NewFileDialog`, `RenameDialog`, etc.) | `KaakaoDialog` |
| Stock `Label` everywhere | `KaakaoLabel` |
| Stock `ToolTip` | `KaakaoToolTip` |
| `PariAppWindow` root | `KaakaoWindow` |
| `PariToolBar` | `KaakaoToolBar` |
| `CustomStatusBar` | `KaakaoStatusBar` |
| Menus (`PariMenuBar`) | `KaakaoMenu` / `KaakaoMenuItem` / `KaakaoMenuSeparator` |
| `SplitView` | `KaakaoSplitView` |

### Remain custom (re-themed via the facade)

- `PariPaperWell` — Atelier recessed "paper well"; no Kaakao equivalent. Colors/inner shadow
  re-based on `Theme.contentBackground` / `Theme.textFieldInnerShadow`.
- `ColorButton` — no Kaakao color picker; rebuilt on `KaakaoButton`.
- `CodeEditorPane`, `LineNumberGutter`, `FindOverlay` (uses `KaakaoSearchField` internally),
  `GitDiffView`, file tree, AI output pane — pari-specific composites.
- `SpinBox` (settings) — Kaakao has only a stepper, no spin box.
- `ScrollView` — no Kaakao equivalent.
- Pari-specific `PariTheme` constants: `editorBgDirty`, `monoFont`, `fontSize*` (appSettings-driven).

### PariTheme facade mapping (Step 2)

| `PariTheme` property | Source |
|---|---|
| `isDark` | `Theme.isDarkMode` (drive `Theme.themeMode` from `appSettings.systemThemeIsDark`) |
| `sidebarBg` | `Theme.sidebarBackground` |
| `sidebarBorder` | `Theme.sidebarBorder` |
| `editorBg` | `Theme.contentBackground` |
| `editorBorder` | `Theme.textFieldBorder` |
| `windowBg` | `Theme.windowBackground` |
| `textColor` | `Theme.primaryText` |
| `textColorMuted`, `textColorDim` | `Theme.secondaryText` |
| `textColorInverse` | `Theme.accentButtonText` |
| `accentColor` | `Theme.primaryAccent` |
| `btnLightTop/Bottom`, `btnDarkTop/Bottom` | `Theme.buttonGradTop/Bottom` (Theme dark-switches itself) |
| `btnLightBorder`, `btnDarkBorder` | `Theme.buttonBorder` |
| `btnLightPrimary*`, `btnDarkPrimary*` | `Theme.accentGradTop/Bottom` |
| `paddingSmall`, `paddingMedium` | `Theme.paddingSmall`, `Theme.paddingMedium` |
| `marginStandard` | `Theme.standardPadding` |
| `borderRadius` | `Theme.radiusStandard` |
| `editorBgDirty`, `monoFont`, `fontSize*`, `fontToolbar`, `fontButton` | stay custom (appSettings-driven) |

---

## Step 1 — Vendor Kaakao and wire up the build ✅

**Status: DONE (commit 5d2389e)**

All tasks completed. Full build compiles, all 150 tests pass (including KaakaoIntegration), --selfcheck OK.

## Step 2 — PariTheme becomes a facade over Kaakao Theme ✅

**Status: DONE (commit 8f4f958)**

All tasks completed. Full build compiles, all 150 tests pass, --selfcheck OK.

## Step 3 — Swap stock controls at usage sites (mechanical, by area)

Three sub-steps, each independently testable:

- **3a — `settings/` + `buildtools/`:** `TextField`→`KaakaoTextField`, `ComboBox`→`KaakaoComboBox`,
  `CheckBox`→`KaakaoCheckBox`, `Dialog`→`KaakaoDialog`, `Label`→`KaakaoLabel`.
  Verify: `tst_SettingsWindow`, `tst_BuildConfigurationDialog`.
- **3b — `sidebar/`:** `NewFileDialog`/`RenameDialog`/`FileInfoDialog` → `KaakaoDialog`;
  `GlobalSearchPane` inputs → `KaakaoSearchField`/`KaakaoTextField`, `CheckBox`→`KaakaoCheckBox`,
  `ProgressBar`→`KaakaoProgressBar`.
  Verify: `tst_RenameDialog`, `tst_FileInfoDialog`, `tst_FileTreeDelegate`.
- **3c — `ai/` + `git/` + `editor/FindOverlay`:** `TextArea`→`KaakaoTextArea`,
  `ComboBox`→`KaakaoComboBox`, busy indication → `KaakaoBusyIndicator`, `ToolTip`→`KaakaoToolTip`,
  `Label`→`KaakaoLabel`, find field → `KaakaoSearchField`.
  Verify: `tst_OutputPane`, `tst_ChatLogWindow`, `tst_GitOutputWindow`, `tst_FindOverlay`.

Verify (each sub-step): affected tests, then full `tst_ui` + `--selfcheck`.

## Step 4 — Replace PariButton and PariIconButton

Replace usages with `KaakaoButton` (primary/default styling per Kaakao API) and `KaakaoToolButton`
for icon buttons; delete both components, their `qmldir`/`qml.qrc` entries, and `tst_PariButton.qml`.

Verify: full suite + `--selfcheck`.

## Step 5 — Replace PariToolButton

Swap to `KaakaoToolButton` in `PariToolBar`, editor gutter, and panes; delete the component,
its `qmldir`/`qml.qrc` entries, and `tst_PariToolButton.qml`.

Verify: `tst_PariToolBar`, full suite, `--selfcheck`.

## Step 6 — Replace the tab bars

Document tabs `PariTabBar` → `KaakaoTabBar`/`KaakaoTabButton`; sidebar strip `PariSidebarTabBar` →
`KaakaoSegmentedControl`; delete both components, their `qmldir`/`qml.qrc` entries, and
`tst_PariTabBar.qml`.

Verify: `tst_CodeEditorPane` (tab interactions), full suite, `--selfcheck`.

## Step 7 — Re-shell the app on Kaakao chrome

`PariAppWindow` root → `KaakaoWindow`; `PariToolBar` → `KaakaoToolBar`; `CustomStatusBar` →
`KaakaoStatusBar`; menus → `KaakaoMenu`/`KaakaoMenuItem`/`KaakaoMenuSeparator`;
`SplitView` → `KaakaoSplitView`. Trim `tst_PariMenuBar`/`tst_PariToolBar`/`tst_CustomStatusBar`
to remaining pari-specific logic.

Verify: full suite + `--selfcheck` + manual run (menus, status bar, splitters).

## Step 8 — Re-base the surviving customs

`PariPaperWell` colors/inner shadow sourced from `Theme.contentBackground`/`textFieldInnerShadow`;
`PariReadOnlyTextArea` → `KaakaoTextArea` (component deleted); `ColorButton` rebuilt on
`KaakaoButton`.

Verify: `tst_ColorButton`, `tst_CodeEditorPane`, `tst_OutputPane`, full suite.

## Step 9 — Cleanup and docs

Prune dead `PariTheme` properties and `qmldir`/`qml.qrc` entries; update `DESIGN.md` (component
inventory, Kaakao as the design base), `project.md`, and `README.md` (dependency note).

Verify: full suite + `--selfcheck` + one coverage run (`./scripts/coverage_report.sh`) to confirm
no test-coverage regression.

---

## Risks

- **Step 1** is the only build-system-risky step: QML module resolution at runtime for the app, the
  test harness, and the installed/bundled app must all be proven there.
- **Steps 6–7** carry the most behavioral risk (tab and shell interactions); they come after the
  facade and leaf swaps are proven.
