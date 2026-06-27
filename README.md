# HXCollectionKit Workspace

This repository is split into two top-level parts:

```text
Package.swift     # Root SwiftPM manifest for remote SPM consumers
HXCollectionKit/   # Library sources, tests, and package-local docs
Example/           # UIKit demo app consuming HXCollectionKit as a local package
Docs/              # Additional design documents
```

## Use HXCollectionKit via SPM

Add this repository URL in Xcode's Swift Package Manager flow. The root package manifest is:

```text
Package.swift
```

For local development, the package-local manifest is also available at `HXCollectionKit/Package.swift`.

The package exposes one library product:

```swift
.product(name: "HXCollectionKit", package: "HXCollectionKit")
```

## Run Tests

```bash
swift test
```

## Run the Example

Open:

```text
Example/HXCollectionKitExample.xcodeproj
```

The example app references the sibling local package at `../HXCollectionKit`, while remote consumers can add the repository root URL directly because `Package.swift` is present at the root.

## More Documentation

- Package README: `HXCollectionKit/README.md`
- Architecture: `HXCollectionKit/Architecture.md`
- Original design document: `Docs/HXCollectionKit-Architecture-Design-v1.0.md`
