# Native feature audit — supplied `VideoStarTool(1).dylib`

## Binary identity

- Format: 64-bit Mach-O dynamic library
- Architecture: ARM64 (`arm64`)
- File type: `MH_DYLIB`
- Size: 1,665,240 bytes
- SHA-256: `42219ad7984e04c400bd2752cb6d4b9c5dfd24670e670b3d54077b815066c2d5`

## Feature and menu evidence

The supplied binary contains the following Objective-C selector strings:

- Menu dispatch: `startFeatureAtIndex:sender:`, `featureSwitchChanged:`
- Media replacement entry point: `startFeatureReplaceMedia`
- Recent code entry point: `startFeatureLastCode`
- Multi-scene entry point: `startFeatureMultiSceneApply`
- Beat entry point: `startFeatureBeatSplit`
- Native QR flow: `readQRCode:`, `selectedCode:withImageData:`, `importedData:code:`, `showMergeScenes`, `startQRImport`
- Layer/scene flow: `layerAtLayerNum:`, `assetForLayer:`, `processSingleCodeImage:index:`, `startSingleCodeImagePickerForIndex:`, `mergeSceneImportedEditor:offset:`, `applyMergeSceneOffset:project:`
- Media completion callback: `mediaApplyFinishChanged:error:`

The companion pseudocode describes the Function tab labels as:

1. Auto nhập ảnh vào các lớp hình ảnh
2. Hiển thị code gần nhất từng nhập
3. Auto chia beat
4. Auto nhập code và ảnh vào các phân cảnh

It also shows `featureSwitchChanged:` persisting a feature-state array and dispatching by feature index. The menu and entry points are therefore present in the supplied native binary; the earlier reconstructed `ExperimentalSources/` project replaced some of these routines with placeholder alerts and must not be used to overwrite this prebuilt library.

## What CI verifies

`scripts/verify_prebuilt.py` checks the Mach-O 64-bit header, ARM64 CPU type, dynamic-library file type, and the selector strings listed above. GitHub Actions then packages the *exact supplied binary* as an artifact.

## What CI cannot verify

This is not a runtime test. It does not launch Video Star, test private APIs, prove compatibility with a particular Video Star build, or prove that every workflow completes on a device. Runtime success must be tested on the target app version with a disposable project. The old pseudocode companion and the new binary differ at 137 byte offsets, so pseudocode/assembly references are analytical aids rather than a guarantee of exact source equivalence.
