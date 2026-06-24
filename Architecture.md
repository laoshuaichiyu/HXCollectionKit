# HXCollectionKit Architecture

## Design Goals

HXCollectionKit is a UIKit-native, Swift 6-friendly collection framework foundation. It keeps business state independent from UIKit while still using modern UIKit APIs: diffable data source, compositional layout, cell registration, drag & drop, context menus, and list swipe actions.

## Module Responsibilities

```text
Core
├─ HXItem / HXSection
├─ HXCollectionState
├─ HXCollectionAction
├─ HXCollectionViewModelProtocol
└─ State mutation helpers

Snapshot
└─ HXSnapshotBuilder

Registration
└─ HXDefaultCellContent

DataSource
└─ HXCollectionDataSource

Layout
├─ HXCollectionLayoutStyle
├─ HXCollectionLayoutConfiguration
└─ HXCollectionLayoutFactory

DragDrop / Interaction
└─ HXCollectionInteractionCoordinator
```

### Core

Core defines data contracts and state. It does not own `UICollectionView`, cells, layout objects, or menu objects.

### Snapshot

Snapshot converts `HXCollectionState` into the framework's single snapshot type. iOS builds use `NSDiffableDataSourceSnapshot`; non-UIKit builds use a lightweight test snapshot.

### DataSource

DataSource owns `UICollectionViewDiffableDataSource` and renders snapshots. It does not decide business mutations.

### Layout

Layout owns compositional layout creation. `ViewController` asks `HXCollectionLayoutFactory` for `list`, `grid`, or `card` layouts instead of building layout trees inline.

### Interaction

Interaction delegates convert UIKit gestures and menus into `HXCollectionAction`. They do not mutate arrays.

## Data Flow

```text
User
↓
UICollectionView interaction
↓
HXCollectionInteractionCoordinator / swipe action
↓
HXCollectionAction
↓
ViewModel.send(action)
↓
HXCollectionState
↓
HXSnapshotBuilder
↓
HXCollectionDataSource.apply
↓
UICollectionViewDiffableDataSource
↓
UICollectionView
```

## ViewModel / DataSource / Layout / Interaction Relationship

- ViewModel owns `HXCollectionState` and handles `HXCollectionAction`.
- DataSource renders snapshots from state.
- Layout factory builds `UICollectionViewCompositionalLayout` instances.
- Interaction coordinator listens to UIKit delegate callbacks and emits actions.
- ViewController binds these pieces together but does not mutate item arrays.

## Why CellRegistration Cannot Be Created in cellProvider

`cellProvider` is invoked repeatedly while the collection view asks for cells. Creating `UICollectionView.CellRegistration` there would:

1. Allocate registration objects repeatedly during scrolling.
2. Mix registration setup with cell rendering.
3. Make reuse behavior harder to reason about.
4. Violate the Registration module responsibility.

HXCollectionKit creates registration objects before data source callbacks and captures the registration for reuse.

## Why Item / Section Should Not Be @MainActor

Item and section values are identity and state models. They may be created by repositories, decoded from network responses, tested on background executors, and passed through async ViewModels. If they are `@MainActor` isolated:

1. Background state generation becomes unnecessarily main-thread bound.
2. Diffable identity values become coupled to UIKit.
3. Swift 6 Sendable checking becomes harder to satisfy.
4. Business models leak presentation-layer constraints.

Instead, `HXItem` and `HXSection` require `Hashable`, `Identifiable`, and `Sendable`, while UIKit-facing coordinators are `@MainActor`.

## Interaction Notes

- Drag starts through `UICollectionViewDragDelegate.itemsForBeginning`.
- Drop is accepted through `dropSessionDidUpdate` returning a local `.move` proposal.
- `performDropWith` sends a `.move` action to the ViewModel.
- ContextMenu emits `.delete`, `.insert`, `.duplicate`, and `.rename` actions.
- List swipe delete is available only for list layouts using `UICollectionLayoutListConfiguration.trailingSwipeActionsConfigurationProvider`.
- Grid/card compositional layouts use ContextMenu deletion because they do not provide list trailing swipe APIs.
