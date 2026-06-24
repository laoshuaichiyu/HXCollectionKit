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
}
