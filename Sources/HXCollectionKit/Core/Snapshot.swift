#if canImport(UIKit)
import UIKit

/// Unified diffable snapshot type for the entire framework.
///
/// Per the architecture document, feature-specific aliases such as
/// `HomeSnapshot` or `Snapshot2` should not be introduced in HXCollectionKit.
public typealias HXCollectionSnapshot<Section: HXSection, Item: HXItem> = NSDiffableDataSourceSnapshot<Section, Item>
#endif
