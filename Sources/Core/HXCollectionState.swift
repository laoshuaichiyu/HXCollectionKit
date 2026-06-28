import Foundation

/// Immutable state consumed by snapshot builders.
///
/// The state is UI-framework agnostic by design: it stores sections and a
/// section-to-items mapping, but never references UICollectionView or diffable
/// data source objects directly.
public struct HXCollectionState<Section: HXSection, Item: HXItem>: Hashable, Sendable {
    public var sections: [Section]
    public var itemsBySection: [Section: [Item]]

    public init(
        sections: [Section] = [],
        itemsBySection: [Section: [Item]] = [:]
    ) {
        self.sections = sections
        self.itemsBySection = itemsBySection
    }

    public subscript(section: Section) -> [Item] {
        get { itemsBySection[section, default: []] }
        set { itemsBySection[section] = newValue }
    }
}
