# Build and runtime status

- Target: iOS dynamic library, ARM64, minimum iOS 15.0.
- CI: GitHub Actions workflow included.
- Local compile: not run in this Linux environment because Apple's iPhoneOS SDK / Xcode linker is unavailable.
- UI: source reconstructed from the previous Xcode scaffold.
- Beat split: best-effort Objective-C state machine using the selectors and flow visible in the supplied pseudocode; runtime behavior unverified.
- Media layer replacement: not complete.
- Last code: not complete.
- Multi-scene apply: not complete.

Do not label a CI artifact as a fully working release until the host integration tests in README.md pass.
