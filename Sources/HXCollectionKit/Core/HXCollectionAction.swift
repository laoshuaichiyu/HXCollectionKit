import Foundation

/// Business-facing actions emitted from the collection layer.
///
/// This type mirrors the unidirectional flow from UIKit events back into the
/// view model while staying independent from UIKit types.
public enum HXCollectionAction<Item: HXItem>: Hashable, Sendable {
    case didSelect(Item)
    case didDeselect(Item)
    case didMove(Item)
    case didDelete(Item)
    case willDisplay(Item)
    case didEndDisplay(Item)
    case prefetch([Item])
    case reload

    case delete(Item)
    case insert(after: Item?)
    case duplicate(Item)
    case rename(Item)
    case move(Item, from: HXCollectionIndexPath?, to: HXCollectionIndexPath)
}

/// Sendable index path representation used by actions crossing the ViewModel boundary.
public struct HXCollectionIndexPath: Hashable, Sendable {
    public var item: Int
    public var section: Int

    public init(item: Int, section: Int) {
        self.item = item
        self.section = section
    }
}
