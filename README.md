F1Vision

Getting Started

1. Requirements
   - Xcode 15 or newer
   - macOS 14+

2. Open the project
   - Open `F1Vision.xcodeproj` in Xcode.
   - Select the shared `F1Vision` scheme and a simulator or device.

3. Build & Run
   - Press Cmd+R to build and run. Mock JSON in `F1Vision/Resources/MockData` is included for out-of-the-box previews.

Optional: Mock Server

If you want to generate live-like race data:
   - Python 3.11+
   - From `MockServer/server`, run according to `README.md` there. Output goes to `MockServer/server/race_output/` (kept via `.gitkeep`, contents ignored).

Notes

- Project files are tracked; only user-specific Xcode data is ignored, so a fresh clone should build without setup.
- Swift Package Manager resolves dependencies via the workspace on first open.

