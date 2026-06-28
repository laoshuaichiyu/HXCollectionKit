import Foundation

/// Pure interaction-to-action mapper used by UIKit coordinators and unit tests.
public enum HXCollectionInteractionActionMapper {
    public static func dragMove<Item: HXItem>(
        item: Item,
        from source: HXCollectionIndexPath?,
        to destination: HXCollectionIndexPath
    ) -> HXCollectionAction<Item> {
        .move(item, from: source, to: destination)
    }

    public static func contextDelete<Item: HXItem>(item: Item) -> HXCollectionAction<Item> {
        .delete(item)
    }

    public static func contextInsert<Item: HXItem>(after item: Item?) -> HXCollectionAction<Item> {
        .insert(after: item)
    }

    public static func contextDuplicate<Item: HXItem>(item: Item) -> HXCollectionAction<Item> {
        .duplicate(item)
    }

    public static func contextRename<Item: HXItem>(item: Item) -> HXCollectionAction<Item> {
        .rename(item)
    }

    public static func swipeDelete<Item: HXItem>(item: Item) -> HXCollectionAction<Item> {
        .delete(item)
    }
}
