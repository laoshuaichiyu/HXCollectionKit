# HXCollectionKit Workspace

This repository is split into two top-level parts:

```text
HXCollectionKit/   # Swift Package library; add this folder/package via SPM
Example/           # UIKit demo app consuming HXCollectionKit as a local package
```

## Use HXCollectionKit via SPM


Add the `HXCollectionKit` package directory or this repository URL in Xcode's Swift Package manager flow. The package manifest lives at:

```text
HXCollectionKit/Package.swift
```

The package exposes one library product:

```swift
.product(name: "HXCollectionKit", package: "HXCollectionKit")
```

## Run Tests

```bash

cd HXCollectionKit

swift test
```

## Run the Example

Open:

```text
Example/HXCollectionKitExample.xcodeproj
```

The example app references the sibling local package at `../HXCollectionKit`, mirroring how an application project can consume HXCollectionKit through Swift Package Manager.

## More Documentation

- Package README: `HXCollectionKit/README.md`
- Architecture: `HXCollectionKit/Architecture.md`

- Original design document: `HXCollectionKit 架构设计文档 v1.0.md`
