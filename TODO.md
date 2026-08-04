# TODO - Auto-fill BPJS form using noPeserta from ApmAntrianModel

## Goal

- In `lib/func/open_aplikasi_bpjsDaftar.dart`, take `noPeserta` from `ApmAntrianModel` and pass it to `sendNoPeserta` to auto-fill the BPJS form.

## Steps

- [x] 1. Add import for `ApmAntrianModel` in `lib/func/open_aplikasi_bpjsDaftar.dart`.
- [ ] 2. Refactor `openExe` to accept `ApmAntrianModel` and extract `noPeserta`.
- [ ] 3. Refactor `sendNoPeserta` to accept `ApmAntrianModel` and use its `noPeserta`.
- [ ] 4. Update `openExeFromMap` to build an `ApmAntrianModel` from the map.
- [ ] 5. Run `flutter analyze` to verify no errors.
