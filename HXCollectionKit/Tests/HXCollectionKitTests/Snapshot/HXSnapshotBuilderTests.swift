import Testing
@testable import HXCollectionKit

@Test func snapshotHasCorrectSectionAndItemCounts() {
    let firstSection = TestSection(id: "first")
    let secondSection = TestSection(id: "second")
    let state = HXCollectionState(
        sections: [firstSection, secondSection],
        itemsBySection: [
            firstSection: [makeItem(1), makeItem(2)],
            secondSection: [makeItem(3)]
        ]
    )

    let snapshot = HXSnapshotBuilder.makeSnapshot(from: state)

    #expect(snapshot.sectionIdentifiers.count == 2)
    #expect(snapshot.itemIdentifiers.count == 3)
}

@Test func snapshotPreservesItemOrder() {
    let section = TestSection(id: "main")
    let items = [makeItem(1), makeItem(2), makeItem(3)]
    let snapshot = HXSnapshotBuilder.makeSnapshot(
        from: HXCollectionState(sections: [section], itemsBySection: [section: items])
    )

    #expect(snapshot.itemIdentifiers == items)
}

@Test func snapshotReflectsDelete() {
    let section = TestSection(id: "main")
    let first = makeItem(1)
    let second = makeItem(2)
    var state = HXCollectionState(sections: [section], itemsBySection: [section: [first, second]])
    state.delete(first)

    let snapshot = HXSnapshotBuilder.makeSnapshot(from: state)

    #expect(snapshot.itemIdentifiers == [second])
}

@Test func snapshotReflectsMove() {
    let section = TestSection(id: "main")
    let first = makeItem(1)
    let second = makeItem(2)
    let third = makeItem(3)
    var state = HXCollectionState(sections: [section], itemsBySection: [section: [first, second, third]])
    state.move(first, to: HXCollectionIndexPath(item: 2, section: 0))

    let snapshot = HXSnapshotBuilder.makeSnapshot(from: state)

    #expect(snapshot.itemIdentifiers == [second, first, third])
}

@Test func snapshotSupportsEmptyData() {
    let snapshot = HXSnapshotBuilder.makeSnapshot(
        from: HXCollectionState<TestSection, TestItem>()
    )

    #expect(snapshot.sectionIdentifiers.isEmpty)
    #expect(snapshot.itemIdentifiers.isEmpty)
}

@Test func snapshotSupportsMultipleSections() {
    let firstSection = TestSection(id: "first")
    let secondSection = TestSection(id: "second")
    let first = makeItem(1)
    let second = makeItem(2)
    let snapshot = HXSnapshotBuilder.makeSnapshot(
        from: HXCollectionState(
            sections: [firstSection, secondSection],
            itemsBySection: [firstSection: [first], secondSection: [second]]
        )
    )

    #expect(snapshot.sectionIdentifiers == [firstSection, secondSection])
    #expect(snapshot.itemIdentifiers == [first, second])
}
