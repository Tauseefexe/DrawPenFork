# Portable Windows Build

This folder describes the **portable** (no-installer) Windows build of DrawPen.

> ⚠️ The runnable binaries are **not committed to git** — the packaged
> `DrawPen.exe` plus Electron DLLs is ~150–200 MB, far above GitHub's 100 MB
> per-file limit. Instead, a GitHub Actions workflow builds the portable
> package on every relevant push (and on manual dispatch) and publishes the
> ZIP to the always-up-to-date **`portable` Release** on GitHub.

---

## What you get

A single downloadable ZIP named `DrawPen-Portable-win32-x64.zip` containing
the full runnable, portable folder:

```
DrawPen-Portable-win32-x64.zip
└── (extracted folder)
    ├── DrawPen.exe            ← main executable (double-click to run)
    ├── PORTABLE-README.txt    ← notes bundled with the build
    ├── resources/
    │   └── app.asar           ← the app code
    ├── locales/               ← Chromium language packs
    ├── *.dll                  ← Electron/Chromium native DLLs (all required)
    └── ...                    ← version, ffmpeg, vk_swiftshader, etc.
```

Usage: extract anywhere, run `DrawPen.exe`. No installation, no admin rights.
To uninstall: delete the folder. App data lives in the user profile and is
created on first run.

## Download

Latest build (always the most recent successful run):

| File | URL |
| ---- | --- |
| ZIP | https://github.com/Tauseefexe/DrawPenFork/releases/download/portable/DrawPen-Portable-win32-x64.zip |
| SHA-256 | https://github.com/Tauseefexe/DrawPenFork/releases/download/portable/DrawPen-Portable-win32-x64.zip.sha256 |

Or one-command download in PowerShell:

```powershell
irm https://raw.githubusercontent.com/Tauseefexe/DrawPenFork/main/portable/get-portable.ps1 | iex
```

Or use the bundled script manually:

```powershell
.\get-portable.ps1
```

## How it is built

The build is defined by [`workflow.yml`](workflow.yml) in this folder (it
must be placed at `.github/workflows/portable.yml` to run — see the activation
instructions at the top of that file — or use the copy committed by the web UI
path described there). The workflow:

1. `npm install` (dependencies)
2. `npm run package_no_sign` → Electron Forge produces `out/<app>-win32-x64/`
3. Verifies `DrawPen.exe`, `resources/` and DLL count
4. Bundles a `PORTABLE-README.txt` inside the package
5. Zips everything (flat layout — exe at ZIP root)
6. Uploads the artifact and publishes it to the `portable` GitHub release

Triggers:

- `workflow_dispatch` (manual, "Run workflow" in Actions)
- push to `main` touching `src/`, `tools/`, `package.json`, or this workflow

Build status: https://github.com/Tauseefexe/DrawPenFork/actions/workflows/portable.yml

## Notes

- Windows Defender/SmartScreen may warn about an unsigned portable exe —
  compare the SHA-256 with the `.sha256` file published next to the ZIP.
- The `portable` tag/release accumulates only the latest ZIP (assets are
  overwritten on each build), so the download URL stays stable.
