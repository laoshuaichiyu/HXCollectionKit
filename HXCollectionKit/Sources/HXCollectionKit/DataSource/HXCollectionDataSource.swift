#if canImport(UIKit)
import UIKit

/// UIKit-backed diffable data source wrapper for HXCollectionKit.
///
/// The wrapper owns `UICollectionViewDiffableDataSource` and exposes a small,
/// business-agnostic mutation API. It must be used on the main actor because it
/// coordinates UIKit objects.
@MainActor
public final class HXCollectionDataSource<Section: HXSection, Item: HXItem> {
    public typealias Snapshot = HXCollectionSnapshot<Section, Item>
    public typealias CellRegistration<Cell: UICollectionViewCell> = UICollectionView.CellRegistration<Cell, Item>
    public typealias CellProvider = @MainActor (
        UICollectionView,
        IndexPath,
        Item
    ) -> UICollectionViewCell?

    private let dataSource: UICollectionViewDiffableDataSource<Section, Item>

    /// Creates a data source with a pre-built, reusable cell registration.
    ///
    /// `cellRegistration` is captured once here and reused for every cell. Do
    /// not create registrations inside `cellProvider` closures at call sites.
    public init<Cell: UICollectionViewCell>(
        collectionView: UICollectionView,
        cellRegistration: CellRegistration<Cell>
    ) {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    /// Creates a data source with a fully custom cell provider.
    ///
    /// Prefer the registration-based initializer whenever possible so cell
    /// registrations are created before data source callbacks begin.
    public init(
        collectionView: UICollectionView,
        cellProvider: @escaping CellProvider
    ) {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
    }

    public func apply(
        _ snapshot: Snapshot,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        dataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences,
            completion: completion
        )
    }

    public func apply(
        state: HXCollectionState<Section, Item>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        apply(
            HXSnapshotBuilder.makeSnapshot(from: state),
            animatingDifferences: animatingDifferences,
            completion: completion
        )
    }

    public func snapshot() -> Snapshot {
        dataSource.snapshot()
    }

    public func itemIdentifier(for indexPath: IndexPath) -> Item? {
        dataSource.itemIdentifier(for: indexPath)
    }

    public func reloadItems(
        _ items: [Item],
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard !items.isEmpty else {
            completion?()
            return
        }

        var snapshot = dataSource.snapshot()
        let existingItems = items.filter { snapshot.itemIdentifiers.contains($0) }

        guard !existingItems.isEmpty else {
            completion?()
            return
        }

        snapshot.reloadItems(existingItems)
        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    public func insertItem(
        _ item: Item,
        in section: Section,
        afterItem: Item? = nil,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var snapshot = dataSource.snapshot()

        if !snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendSections([section])
        }

        if let afterItem, snapshot.itemIdentifiers.contains(afterItem) {
            snapshot.insertItems([item], afterItem: afterItem)
        } else {
            snapshot.appendItems([item], toSection: section)
        }

        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    public func deleteItems(
        _ items: [Item],
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard !items.isEmpty else {
            completion?()
            return
        }

        var snapshot = dataSource.snapshot()
        let existingItems = items.filter { snapshot.itemIdentifiers.contains($0) }

        guard !existingItems.isEmpty else {
            completion?()
            return
        }

        snapshot.deleteItems(existingItems)
        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    public func moveItem(
        _ item: Item,
        afterItem: Item,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var snapshot = dataSource.snapshot()

        guard snapshot.itemIdentifiers.contains(item),
              snapshot.itemIdentifiers.contains(afterItem) else {
            completion?()
            return
        }

        snapshot.moveItem(item, afterItem: afterItem)
        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    public func moveItem(
        _ item: Item,
        beforeItem: Item,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var snapshot = dataSource.snapshot()

        guard snapshot.itemIdentifiers.contains(item),
              snapshot.itemIdentifiers.contains(beforeItem) else {
            completion?()
            return
        }

        snapshot.moveItem(item, beforeItem: beforeItem)
        apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
}

public extension HXCollectionDataSource where Item: HXDefaultCellContent {
    /// Builds the framework default list-cell data source.
    ///
    /// The registration is created once before the diffable data source is
    /// initialized and is then reused by UIKit's cell provider callback.
    convenience init(
        collectionView: UICollectionView
    ) where Section: HXSection {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.title
            configuration.secondaryText = item.subtitle

            if let imageSystemName = item.imageSystemName {
                configuration.image = UIImage(systemName: imageSystemName)
            } else {
                configuration.image = nil
            }

            cell.contentConfiguration = configuration
        }

        self.init(
            collectionView: collectionView,
            cellRegistration: registration
        )
    }
}
#endif
