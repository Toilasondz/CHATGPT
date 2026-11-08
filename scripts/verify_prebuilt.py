#!/usr/bin/env python3
"""Structural and feature-selector audit for the supplied iOS Mach-O dylib."""
from __future__ import annotations
import hashlib
import pathlib
import struct
import sys

path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "Prebuilt/VideoStarTool.dylib")
data = path.read_bytes()
if len(data) < 32:
    raise SystemExit("FAIL: file is too small to be a Mach-O header")
magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = struct.unpack_from("<IiiIIIII", data, 0)
checks = [
    (magic == 0xFEEDFACF, "64-bit Mach-O magic"),
    (cputype == 0x0100000C, "ARM64 CPU type"),
    (filetype == 6, "MH_DYLIB file type"),
]
for ok, label in checks:
    print(("PASS" if ok else "FAIL") + ": " + label)
if not all(ok for ok, _ in checks):
    raise SystemExit(1)

selectors = [
    "startFeatureReplaceMedia",
    "startFeatureLastCode",
    "startFeatureMultiSceneApply",
    "startFeatureBeatSplit",
    "startFeatureAtIndex:sender:",
    "featureSwitchChanged:",
    "selectedCode:withImageData:",
    "importedData:code:",
    "readQRCode:",
    "showMergeScenes",
    "startQRImport",
    "layerAtLayerNum:",
    "assetForLayer:",
    "mergeSceneImportedEditor:offset:",
    "mediaApplyFinishChanged:error:",
    "processSingleCodeImage:index:",
    "startSingleCodeImagePickerForIndex:",
    "applyMergeSceneOffset:project:",
]
missing = []
for selector in selectors:
    present = selector.encode("utf-8") in data
    print(("PASS" if present else "FAIL") + ": selector " + selector)
    if not present:
        missing.append(selector)
if missing:
    raise SystemExit("Missing required selector strings: " + ", ".join(missing))

print(f"Size: {len(data):,} bytes")
print("SHA-256: " + hashlib.sha256(data).hexdigest())
print("NOTE: this audit verifies architecture and embedded selector strings, not runtime behavior inside Video Star.")
