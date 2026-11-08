# Reverse-engineering notes

Recovered IMP ranges from the supplied pseudocode/disassembly:

- Media layer apply: `0xb4b0`–`0xeaf0`
- Beat split: `0x100c0`–`0x11c48`
- Multi-scene apply: `0x12c64`–`0x184e4`

Key host runtime symbols visible in the pseudocode include:

- Classes: `VideoReviewEditVC`, `MultiSplitView`, `MultiLayerNavController`, `MultiLayerWizEffectVC`, `QRCodeManager`
- Layer access: `getMultiLayerEngine`, `layerAtLayerNum:`, `assetForLayer:`, `selectLayer:bordered:`
- Beat workflow: `beatModeOn`, `toggleBeatMode`, `jumpToNextBeat`, `setSplitPoint`, `hasNextBeat`, `doSplit`, `sceneCount`
- QR / multi-scene workflow: `showMergeScenes`, `startQRImport`, `selectedCode:withImageData:`, `importedData:code:`

These names were recovered as strings/selectors. Their availability, signatures, and semantics still need to be confirmed at runtime for the target Video Star build.
