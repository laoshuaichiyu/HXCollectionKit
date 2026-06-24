import Testing
@testable import HXCollectionKit

@Test func dragMoveMapsToViewModelMoveAction() {
    let item = makeItem(1)
    let source = HXCollectionIndexPath(item: 0, section: 0)
    let destination = HXCollectionIndexPath(item: 1, section: 0)

    let action = HXCollectionInteractionActionMapper.dragMove(
        item: item,
        from: source,
        to: destination
    )

    #expect(action == .move(item, from: source, to: destination))
}

@Test func contextDeleteMapsToDeleteAction() {
    let item = makeItem(1)

    #expect(HXCollectionInteractionActionMapper.contextDelete(item: item) == .delete(item))
}

@Test func contextDuplicateMapsToDuplicateAction() {
    let item = makeItem(1)

    #expect(HXCollectionInteractionActionMapper.contextDuplicate(item: item) == .duplicate(item))
}

@Test func contextRenameMapsToRenameAction() {
    let item = makeItem(1)

    #expect(HXCollectionInteractionActionMapper.contextRename(item: item) == .rename(item))
}

@Test func swipeDeleteMapsToDeleteAction() {
    let item = makeItem(1)

    #expect(HXCollectionInteractionActionMapper.swipeDelete(item: item) == .delete(item))
}
