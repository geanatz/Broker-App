Multi-phase improvement plan
Phase 1: Immediate stability and UX fixes (safe, minimal changes)
Goals:
Eliminate double-trigger bug.
Make asset selection and version parsing robust.
Sanitize paths during extraction. Add basic disk/permission checks.
Clean UI callback lifecycle; remove emojis from logs; keep concise logs.
Actions/changes:
In splash_screen.dart _showUpdateDialog(): remove _startCompleteUpdate() from the "Actualizeaza" button; only return true. The caller handles the download dialog.
Improve _getDownloadUrl to select by exact asset name with platform arch awareness; prefer .exe installer (see Phase 2) or .zip fallback; ensure .zip extension if ZIP chosen.
Improve _isNewerVersion to support SemVer with pre-release/build metadata; ignore pre-release by default unless enableBetaUpdates is true.
Sanitize archive entries to prevent path traversal: reject entries containing .., drive letters, or absolute paths.
Unset or scope UI callbacks after dialog completes to avoid leaks.
Replace emoji logs in splash update code with clean text logs per preference and keep them minimal.
Risks:
Small chance of mismatching asset if release naming is inconsistent.
Mitigation:
Add config to pin expected asset name; log chosen asset name.
Expected outcome:
No race conditions; safer extraction; cleaner logs; better asset targeting.
Test/verify:
Simulate pre-release tags; assert version comparator works.
Simulate ZIP with malicious paths; verify rejection.
Confirm only one download/install runs per confirmation.
Implemented in code:
- Hardened version parsing to support SemVer with pre-release/build metadata; removed emoji from version-compare error log. File: `lib/backend/services/update_service.dart` (_isNewerVersion).
- Asset selection now prefers exact match for installer (`UpdateConfig.getInstallerName()`), then exact zip name (`getWindowsAssetName()`), then base-name partial match as last resort. File: `update_service.dart` (_getDownloadUrl).
- Added UI callback lifecycle management: `clearUICallbacks()` and changed setter signatures to accept nullable to allow clearing. File: `update_service.dart`.
- After download dialog completes, UI callbacks are cleared to avoid leaks. File: `lib/frontend/screens/splash_screen.dart` (_showUpdateDownloadDialog).
- After download completes, the "Instaleaza acum" action now opens a minimal installing dialog and triggers `installUpdate()` reliably. File: `lib/frontend/screens/splash_screen.dart` (_showInstallDialog implemented).
 - Fixed download dialog state updates to use the dialog's own `StatefulBuilder` setState, so progress and completion actions appear reliably. File: `lib/frontend/screens/splash_screen.dart` (_showUpdateDownloadDialog uses local dialogSetState).
 - Ensured update dialog lifecycle is respected: we now await the dialog's completion before clearing callbacks or navigating away, preventing the popup from disappearing before installation. File: `lib/frontend/screens/splash_screen.dart` (_showUpdateDownloadDialog awaits `showDialog`).
- Removed double-trigger: "Actualizeaza" button in splash dialog now only returns true (no direct start). File: `lib/frontend/screens/splash_screen.dart` (_showUpdateDialog). Also removed unused `_startCompleteUpdate()`.
- Removed emojis from update-related splash logs and standardized concise logs. File: `lib/frontend/screens/splash_screen.dart`.
- Added extraction path sanitization to prevent directory traversal and unsafe writes; added write permission probe and early error if app dir not writable. File: `lib/backend/services/update_service.dart` (_installWindowsUpdate loop and pre-check).
 - Added persistent file logging usable in release builds. Implemented `AppLogger.initFileLogging(path)` writing to `logs.txt` in app directory, no emojis by default, verbose on. Integrated structured logs across `UpdateService` (check, download, install, backup, rollback, restart). Files: `lib/backend/services/app_logger.dart`, `lib/backend/services/update_service.dart`.
Phase 2: Replace batch/CMD with installer-based updates (preferred, minimal dependencies)
Goals:
Remove CMD/batch scripts and locked-file hacks.
Use the app’s official installer (BrokerAppInstaller.exe) with silent upgrade flags.
Actions/changes:
Publish a release asset BrokerAppInstaller.exe that supports silent upgrade (e.g., MSI /quiet, NSIS /S, Inno /VERYSILENT /SUPPRESSMSGBOXES, MSIX supports App Installer updates).
 Change _getDownloadUrl to prefer windowsInstallerName (behind config flag `preferInstallerAsset`).
In installUpdate(), if installer asset is available:
Download installer to AppData.
 Spawn installer directly using Process.start(installerPath, ['silent-flags'], runInShell: false) with proper flags; no cmd.
Show an in-app “Installing update…” overlay; the installer will close/restart the app as needed.
Keep ZIP path as fallback if installer missing, but block in-app overwrite when app runs from Program Files; suggest running installer flow instead.
Risks:
Requires installer changes if not yet supporting silent upgrade; elevation prompts may appear.
Mitigation:
Document and standardize installer flags; sign the installer; handle exit codes; if elevation needed, inform user in UI.
Expected outcome:
No CMD windows; robust replacements of locked files; fewer file IO issues.
Test/verify:
Implemented prep work in code:
- Added `preferInstallerAsset` and `windowsInstallerSilentArgs` in `UpdateConfig` and modified `_getDownloadUrl` to prefer installer when present. Files: `lib/backend/services/update_config.dart`, `lib/backend/services/update_service.dart`.
- `_downloadUpdate()` now saves installer with correct filename and validates size with `_validateInstallerDownload()`.
 - Added installer execution path: if the downloaded asset is `.exe`, the app launches it without CMD using `Process.start` and exits, letting the installer perform the in-place upgrade and restart. Detailed debug logs were added: `installer_launch`, `installer_started`, `exit_for_installer`. Files: `lib/backend/services/update_service.dart`.
Run installer silent upgrade in a non-admin and admin scenario; assert correct version after restart; capture installer exit codes and errors.
Phase 3: Integrity and security validation
Goals:
Prevent tampering and network attacks; ensure update authenticity.
Actions/changes:
For each release, publish BrokerAppInstaller.exe.sha256 and/or broker-app-windows.zip.sha256. Optionally publish a signed checksum file (minisign or GPG).
Download checksum asset; compute local SHA-256; compare; abort if mismatch.
If using ZIP fallback: enforce path sanitation and optionally require signature inside the archive (signed manifest).
Enforce HTTPS and reasonable timeouts; optional GitHub API token to avoid rate limits.
Risks:
Operational overhead to publish checksums.
Mitigation:
Automate checksum generation in CI.
Expected outcome:
Strong integrity guarantees; safer distribution.
Test/verify:
Corrupt downloads in tests; assert install aborts.
Wrong checksum asset; assert installer is not executed.
Implemented prep work in code:
- Added checksum validation support: `_checksumUrl` detection, `_validateChecksum()` with SHA-256, structured logs `checksum_start`, `checksum_result`, `checksum_mismatch_delete_file`. File: `lib/backend/services/update_service.dart`.
Phase 4: Streamed install and lean backups (ZIP fallback path)
Goals:
Reduce memory/disk footprint; faster and safer fallbacks.
Actions/changes:
Replace readAsBytes() with streamed ZIP extraction to disk.
Backup policy:
Exclude cache/logs and downloaded update artifacts.
Use differential backup for large dirs (copy only changed files) or zipped backup.
Cap size and age; use maxBackups.
Pre-flight checks: free disk space, write permission to target dir; if target is under Program Files, force installer route instead of ZIP fallback.
Risks:
Complexity in streamed extraction and diff backup logic.
Mitigation:
Use a well-tested streaming unzip or implement a simple per-file streaming write with CRC checks.
Expected outcome:
Lower memory usage; faster updates; predictable disk usage.
Test/verify:
Large ZIP update on low-RAM VM; monitor memory; verify backup excludes.
Phase 5: Background download + staged install with better UX
Goals:
Make updates unobtrusive; let users choose install timing; keep app responsive.
Actions/changes:
Keep background periodic checks; start background download when idle.
When download ready, show a small notification bar (re-enable UpdateNotification with an action) and a compact dialog: “Update ready. Install now or later.”.
Add “Remind me later” options (e.g., next launch, tomorrow) and “Skip this version”.
Render release notes with lightweight markdown (optional); or format bullets nicely.
Persist user choices by version to avoid nagging.
Risks:
Notification complexity.
Mitigation:
Keep UI minimal; reuse existing UpdateNotificationWrapper.
Expected outcome:
Smooth updates with minimal interruptions.
Test/verify:
E2E flows: background download, notify, install later/now; ensure state survives restarts.
Phase 6: Architecture cleanup and testing
Goals:
Increase maintainability and testability.
Actions/changes:
Split UpdateService into:
UpdateRepository (GitHub fetch, checksum fetch).
UpdateDownloader (download streams, resume, progress).
UpdateInstaller (installer execution or ZIP fallback).
UpdateState exposed via stream for UI.
Add unit tests for version logic, asset selection, checksum validation, path sanitation.
Standardize logging: concise, no emojis, categorized.
Risks:
Refactor touches multiple files.
Mitigation:
Keep public API stable; mark old methods as deprecated and adapt call sites gradually.
Expected outcome:
Clear separation of concerns; easier to extend to macOS/Linux later.
Test/verify:
Run unit and integration tests; manual smoke on Windows.
Phase 7: Optional dedicated updater (if installer is not an option)
Goals:
Remove batch scripts without relying on an external installer.
Actions/changes:
Ship a tiny BrokerUpdater.exe (GUI-less, signed) alongside the app.
App downloads ZIP, extracts to temp, then spawns the updater with args: target dir, temp dir, target exe path.
Updater waits for app to exit, replaces files (uses Restart Manager, PendingFileRenameOperations if needed), cleans temp, restarts app.
App shows progress and closes after spawning updater.
Risks:
Additional binary to maintain.
Mitigation:
Minimal code; stable API; sign binary; version it with the app.
Expected outcome:
Zero CMD; robust file replacement under locks; no reliance on installer tech.
Test/verify:
Locked files scenario; denied permissions; ensure reliable restart and cleanup.
How the GUI should work (end state)
Non-blocking: background checks; if update found, a small in-app bar appears at the top: “Update 1.4.2 ready.” Buttons: Install now, Details, Later.
Details opens a modal with:
Current vs latest version.
Release notes (bulleted; optional markdown).
Estimated time and a simple progress component during download/installation.
Install now:
If installer is available: start silent installer; show “Installing…” overlay; app closes when needed, installer restarts app.
If ZIP fallback: close app, hand off to updater.exe; restart app after completion.
Settings page:
Toggle auto-download updates.
Toggle auto-install on next launch.
Show current version, last checked time, check now.
Backward compatibility and dependencies
Preserve GitHub Releases flow.
Prefer installer asset if present; keep ZIP fallback.
Avoid new heavy dependencies; optional small updater binary only if installer cannot be used.
No CMD/terminal visible to the user; no .bat scripts.
Verification summary per phase
Phase 1: Manual E2E through splash; unit test version parsing and path sanitation.
Phase 2: Installer silent upgrade test matrix (user/admin, Program Files vs user dir); verify exit codes.
Phase 3: Hash mismatch tests and negative cases; ensure hard fail and cleanup.
Phase 4: Large update performance test; memory profile; backup contents validation.
Phase 5: UX flows: remind later, skip version, state persistence across restarts.
Phase 6: Unit and integration test coverage for split services.
Phase 7: Updater binary E2E with locked files and policy restrictions.
Remove CMD dependency:
Use direct Process.start(installerPath, flags, runInShell: false) and ensure the installer is built as GUI subsystem to avoid console windows.
If using updater binary, build as GUI subsystem too; never spawn cmd, never create .bat.
Additional guardrails:
Reject updates that downgrade version unless enableBetaUpdates or explicit flag.
Disk space check before download and before backup/extract.
Abort if install target is in Program Files and we are not elevated; prompt to run installer flow.
Sanitize archive names and enforce allowed extensions; strip leading separators; normalize paths.
Minimal code edits to start with (Phase 1, high priority):
Remove _startCompleteUpdate() from the “Actualizeaza” button handler in splash_screen.dart and rely on the caller to open the download dialog and start the download.
Harden _getDownloadUrl to pick an exact match for windowsInstallerName first; only then fallback to windowsAssetName .zip.
Improve version parser to tolerate pre-release suffixes.
Sanitize archive entry paths when extracting.
Stop setting persistent callbacks on UpdateService without unsetting them after dialog completion.
Replace emoji debug prints in splash update flow with concise plain logs.
Success criteria:
No console windows ever appear during the update.
Update succeeds when app is installed in Program Files (via installer flow).
Corrupted downloads are detected and do not install.
Users can defer or skip a version; no update runs without clear intent unless auto-install is enabled.
Update logic remains stable under network errors and slow conditions.
Rollout suggestion:
Phase 1 fixes first.
Adopt installer-based updates (Phase 2) next; release once stable.
Add checksum validation (Phase 3).
Continue with performance and UX improvements as follow-ups.
Potential risks and mitigations across the plan:
Installer differences: document and align on a single installer tech and its silent flags.
Elevated permissions: clearly inform users; catch installer exit codes; provide fallback guidance.
Breaking older flows: maintain ZIP fallback but make it safe; detect Program Files and redirect to installer update.
How to test without CMD/terminal for end users:
Use automated scripts in CI to simulate updates and check results.
In-app E2E flows rely on UI and programmatic process spawning only.
No new heavy dependencies:
Use current http, archive (stream mode) where needed.
Optional: a small updater binary only if installer cannot do silent upgrades.
Preserve backward compatibility:
Continue to read GitHub Releases API; support both installer and zip assets.
Keep UpdateConfig flags and messages; add only minimal fields for checksums and asset preference.
Final note:
The installer-first approach is the cleanest way to remove CMD reliance and handle locked files and elevation properly, while keeping the UX simple and reliable.
I can implement Phase 1 changes next, then proceed to Phase 2 (installer-based updates). Let me know if your installer supports silent upgrades and the exact flags, or if you prefer the optional updater binary route.