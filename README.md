# VideoStarTool — native ARM64 dylib package

## Important discovery

The newly supplied `VideoStarTool(1).dylib` already contains the three feature entry points that were missing from the earlier reconstructed source project:

- `startFeatureReplaceMedia`
- `startFeatureLastCode`
- `startFeatureMultiSceneApply`

It also contains `startFeatureAtIndex:sender:` and `featureSwitchChanged:` for the Function-tab dispatch, plus native QR, scene, media-completion and layer selectors. The companion pseudocode shows all four Function-tab labels and the feature-index dispatch.

**Do not build the old experimental source project over this binary.** Its `startFeatureReplaceMedia`, `startFeatureLastCode`, and `startFeatureMultiSceneApply` methods are placeholder alerts, not the implementations in the supplied native library.

## GitHub workflow

The GitHub Actions workflow is named **Verify and package native VideoStarTool dylib**. Push this repository to GitHub and open **Actions**. It will:

1. Validate that the binary is a 64-bit ARM64 Mach-O dynamic library.
2. Check that the menu dispatch and feature-related Objective-C selector strings are present.
3. Package the exact supplied dylib into `VideoStarTool-iOS-arm64-native.zip` and upload it as a workflow artifact.

This workflow **validates and packages an already-built dylib**. It does not recompile source code, because the complete original source is not available. This avoids silently replacing the native implementation with the incomplete experimental reconstruction.

## Files

- `Prebuilt/VideoStarTool.dylib` — exact copy of the newly supplied binary.
- `Verification/NativeFeatureAudit.md` — observed selectors and limitations.
- `Verification/SHA256SUMS.txt` — SHA-256 checksum.
- `ReverseEngineering/` — companion pseudocode and ARM64 disassembly extracts from the supplied binary.
- `ExperimentalSources/` — earlier reconstructed source scaffold, retained for study only; it is not used by CI and is not a source-equivalent rebuild.
- `scripts/verify-prebuilt.sh` — CI/local verification entry point.

## Runtime compatibility

A structurally valid ARM64 dylib is not automatically installable or compatible with every Video Star version. The host app must load the library using an authorized development/test setup. No code-signing bypass, IPA patching, or device installation is performed here.

The selector audit is not a 100% runtime guarantee. Test each feature inside the exact Video Star version and iOS device with a disposable project before relying on it.
