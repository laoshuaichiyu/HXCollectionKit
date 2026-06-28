import Foundation

public extension HXCollectionState {
    mutating func insert(
        _ item: Item,
        in section: Section,
        at index: Int? = nil
    ) {
        if !sections.contains(section) {
            sections.append(section)
        }

        var items = itemsBySection[section, default: []]
        let insertionIndex = min(max(0, index ?? items.count), items.count)
        items.insert(item, at: insertionIndex)
        itemsBySection[section] = items
    }

    mutating func delete(_ item: Item) {
        guard let location = location(of: item) else {
            return
        }

        itemsBySection[location.section]?.remove(at: location.index)
    }

    mutating func move(
        _ item: Item,
        to destination: HXCollectionIndexPath
    ) {
        guard let source = location(of: item),
              sections.indices.contains(destination.section) else {
            return
        }

        let destinationSection = sections[destination.section]
        var sourceItems = itemsBySection[source.section, default: []]
        sourceItems.remove(at: source.index)
        itemsBySection[source.section] = sourceItems

        var destinationItems = itemsBySection[destinationSection, default: []]
        let adjustedDestinationIndex: Int
        if source.section == destinationSection, source.index < destination.item {
            adjustedDestinationIndex = max(0, destination.item - 1)
        } else {
            adjustedDestinationIndex = destination.item
        }

        let targetIndex = min(max(0, adjustedDestinationIndex), destinationItems.count)
        destinationItems.insert(item, at: targetIndex)
        itemsBySection[destinationSection] = destinationItems
    }

    func location(
        of item: Item
    ) -> (section: Section, index: Int)? {
        for section in sections {
            guard let index = itemsBySection[section]?.firstIndex(of: item) else {
                continue
            }
            return (section, index)
        }
        return nil
    }
}
