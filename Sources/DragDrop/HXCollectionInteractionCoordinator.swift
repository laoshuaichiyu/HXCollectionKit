#if canImport(UIKit)
import UIKit

/// Bridges UICollectionView interaction delegates to HXCollectionAction.
///
/// This object owns no collection state. It only resolves the interacted item
/// and forwards an action to the ViewModel boundary.
@MainActor
public final class HXCollectionInteractionCoordinator<Section: HXSection, Item: HXItem>: NSObject,
    UICollectionViewDelegate,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate
{
    public typealias ItemResolver = @MainActor (IndexPath) -> Item?
    public typealias ActionHandler = @MainActor (HXCollectionAction<Item>) -> Void

    private weak var collectionView: UICollectionView?
    private let itemResolver: ItemResolver
    private let actionHandler: ActionHandler

    public init(
        collectionView: UICollectionView,
        itemResolver: @escaping ItemResolver,
        actionHandler: @escaping ActionHandler
    ) {
        self.collectionView = collectionView
        self.itemResolver = itemResolver
        self.actionHandler = actionHandler
        super.init()
    }

    public func bind() {
        collectionView?.delegate = self
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        collectionView?.dragInteractionEnabled = true
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard let item = itemResolver(indexPath) else {
            return []
        }

        let provider = NSItemProvider(object: String(describing: item.id) as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = DragPayload(item: item, sourceIndexPath: indexPath)
        return [dragItem]
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard session.localDragSession != nil else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }

        return UICollectionViewDropProposal(
            operation: .move,
            intent: .insertAtDestinationIndexPath
        )
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        guard let item = coordinator.items.first,
              let payload = item.dragItem.localObject as? DragPayload<Item> else {
            return
        }

        let destinationIndexPath = coordinator.destinationIndexPath
            ?? IndexPath(item: collectionView.numberOfItems(inSection: payload.sourceIndexPath.section), section: payload.sourceIndexPath.section)

        let action = HXCollectionInteractionActionMapper.dragMove(
            item: payload.item,
            from: payload.sourceIndexPath.hxIndexPath,
            to: destinationIndexPath.hxIndexPath
        )

        actionHandler(action)
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = itemResolver(indexPath) else {
            return nil
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }

            let insert = UIAction(title: "Insert", image: UIImage(systemName: "plus")) { [weak self] _ in
                self?.actionHandler(HXCollectionInteractionActionMapper.contextInsert(after: item))
            }
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
                self?.actionHandler(HXCollectionInteractionActionMapper.contextDuplicate(item: item))
            }
            let rename = UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.actionHandler(HXCollectionInteractionActionMapper.contextRename(item: item))
            }
            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.actionHandler(HXCollectionInteractionActionMapper.contextDelete(item: item))
            }

            return UIMenu(children: [insert, copy, rename, delete])
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = itemResolver(indexPath) else {
            return
        }

        Task { @MainActor in
            await actionHandler(.didSelect(item))
        }
    }
}

private final class DragPayload<Item: HXItem> {
    let item: Item
    let sourceIndexPath: IndexPath

    init(item: Item, sourceIndexPath: IndexPath) {
        self.item = item
        self.sourceIndexPath = sourceIndexPath
    }
}

private extension IndexPath {
    var hxIndexPath: HXCollectionIndexPath {
        HXCollectionIndexPath(item: item, section: section)
    }
}
#endif
