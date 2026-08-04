# TODO - Fix auto-fill BPJS form (After.exe)

## Problem

Keystrokes are sent to the wrong window. Each `sendKeys` call spawns a new PowerShell console window that steals focus from the After.exe form, so `SendKeys.SendWait` types into the PowerShell window instead of the After.exe form.

## Steps

- [x] 1. Modify `sendKeys` in `lib/func/open_aplikasi_bpjsDaftar.dart`:
  - Add `-WindowStyle Hidden` so the PowerShell window never appears/steals focus.
  - Activate the After.exe window (`SetForegroundWindow`) inside the same script right before `SendKeys.SendWait`.
- [x] 2. Verify all callers (`sendVirtualKey`, `sendAutoLogin`, `sendNoPeserta`) route through `sendKeys` and benefit automatically.
- [x] 3. Rebuild and test the automation flow.
  - `flutter analyze` passes (only pre-existing info lints, no errors).
  - Verify PowerShell script syntax.
