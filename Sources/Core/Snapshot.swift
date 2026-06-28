#if canImport(UIKit)
import UIKit

/// Unified diffable snapshot type for the entire framework.
///
/// Per the architecture document, feature-specific aliases such as
/// `HomeSnapshot` or `Snapshot2` should not be introduced in HXCollectionKit.
public typealias HXCollectionSnapshot<Section: HXSection, Item: HXItem> = NSDiffableDataSourceSnapshot<Section, Item>
#else
import Foundation

/// Lightweight non-UIKit snapshot used by package tests on platforms where
/// UIKit is unavailable. iOS builds use NSDiffableDataSourceSnapshot instead.
public struct HXCollectionSnapshot<Section: HXSection, Item: HXItem>: Hashable, Sendable {
    public private(set) var sectionIdentifiers: [Section] = []
    public private(set) var itemIdentifiers: [Item] = []
    public private(set) var itemsBySection: [Section: [Item]] = [:]

    public init() {}

    public mutating func appendSections(_ sections: [Section]) {
        for section in sections where !sectionIdentifiers.contains(section) {
            sectionIdentifiers.append(section)
            itemsBySection[section] = itemsBySection[section, default: []]
        }
    }

    public mutating func appendItems(_ items: [Item], toSection section: Section? = nil) {
        guard let section = section ?? sectionIdentifiers.last else {
            return
        }

        if !sectionIdentifiers.contains(section) {
            appendSections([section])
        }

        itemsBySection[section, default: []].append(contentsOf: items)
        itemIdentifiers.append(contentsOf: items)
    }
}
#endif
