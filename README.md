# HXCollectionKit

HXCollectionKit is a Swift 6, iOS 16+, UIKit-native collection framework foundation for MVVM apps. It wraps `UICollectionViewDiffableDataSource`, `UICollectionViewCompositionalLayout`, `UICollectionView.CellRegistration`, drag & drop, context menus, and list swipe actions behind small, testable APIs.

The goal is not to provide a demo-only helper. The goal is a maintainable foundation where business state stays independent from UIKit and rendering is handled by the collection layer.

## Architecture

```text
Business / ViewModel
        │
        ▼
HXCollectionState + HXCollectionAction
        │
        ▼
HXSnapshotBuilder ──► HXCollectionSnapshot
        │
        ▼
HXCollectionDataSource ──► UICollectionViewDiffableDataSource
        │
        ▼
UICollectionView
        ▲
        │
HXCollectionInteractionCoordinator
Drag / Drop / ContextMenu / Selection
```

## Modules

| Module | Responsibility |
| --- | --- |
| Core | `HXItem`, `HXSection`, state, actions, ViewModel protocol, mutation helpers |
| Snapshot | Build a unified snapshot from UI-independent state |
| DataSource | Render snapshots through `UICollectionViewDiffableDataSource` |
| Registration | Default cell content contract and reusable CellRegistration setup |
| Layout | `list`, `grid`, and `card` compositional layout factory |
| DragDrop | Drag/drop, context menu, and delegate interaction bridge |
| Example | UIKit app without Storyboards |

## Quick Start

```swift
struct Section: String, HXSection {
    case main
    var id: String { rawValue }
}

struct Item: HXDefaultCellContent {
    let id: UUID
    let title: String
    let subtitle: String?
    let imageSystemName: String?
}

let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: HXCollectionLayoutFactory.makeLayout(style: .list)
)
let dataSource = HXCollectionDataSource<Section, Item>(collectionView: collectionView)

let state = HXCollectionState(
    sections: [.main],
    itemsBySection: [.main: [
        Item(id: UUID(), title: "Hello", subtitle: "HXCollectionKit", imageSystemName: "star")
    ]]
)
dataSource.apply(state: state, animatingDifferences: true)
```

## API Examples

### Generate and Apply Snapshot

```swift
let snapshot = HXSnapshotBuilder.makeSnapshot(from: state)
dataSource.apply(snapshot)
```

### Switch Layout at Runtime

```swift
collectionView.setCollectionViewLayout(
    HXCollectionLayoutFactory.makeLayout(style: .grid),
    animated: true
)
```

### Bind Interactions to ViewModel

```swift
let interaction = HXCollectionInteractionCoordinator<Section, Item>(
    collectionView: collectionView,
    itemResolver: { dataSource.itemIdentifier(for: $0) },
    actionHandler: { action in
        Task {
            await viewModel.send(action)
            dataSource.apply(state: await viewModel.state)
        }
    }
)
interaction.bind()
```

## Demo App

The example app demonstrates:

- list / grid / card layout switching
- add item button
- delete item via ContextMenu and list swipe actions
- insert, copy, and rename from ContextMenu
- drag sorting and move actions
- same-section and cross-section state moves
- ViewModel-owned state mutations

Open `Example/HXCollectionKitExample.xcodeproj` in Xcode and run the `HXCollectionKitExample` target on iOS 16+.

## Swift 6 Concurrency Notes

- `HXItem` and `HXSection` are `Hashable`, `Identifiable`, and `Sendable`.
- Item and section models should not be `@MainActor` isolated. They represent data identity and may be produced by repositories or ViewModels off the main actor.
- UIKit-facing objects such as `HXCollectionDataSource` and `HXCollectionInteractionCoordinator` are `@MainActor` because they coordinate UIKit.
- Default image content uses `imageSystemName` instead of storing `UIImage` in the model, keeping item models Sendable and UIKit-independent.

## FAQ

### Why not let ViewController mutate arrays directly?

Because the data flow should remain unidirectional: interaction becomes `HXCollectionAction`, ViewModel updates `HXCollectionState`, DataSource renders a snapshot.

### Why use CellRegistration?

`UICollectionView.CellRegistration` keeps cell configuration reusable and type-safe. HXCollectionKit creates registrations before cell provider callbacks and reuses them for every dequeue.

### Why not create CellRegistration inside `cellProvider`?

Creating registrations inside `cellProvider` allocates repeated registration objects during scrolling and mixes registration with rendering. Registrations must be created once and reused.

### Why is there no UITableView adapter?

Version 1 focuses on `UICollectionView`, matching the architecture document. UITableView support would introduce extra abstraction and conditional behavior that belongs in a future version.
