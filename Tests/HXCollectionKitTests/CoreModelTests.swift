import Testing
@testable import HXCollectionKit

private struct TestSection: HXSection {
    let id: String
}

private struct TestItem: HXDefaultCellContent {
    let id: Int
    let title: String
    let subtitle: String?
    let imageSystemName: String?
}

@Test func stateStoresSectionsAndItems() {
    let section = TestSection(id: "main")
    let item = TestItem(id: 1, title: "Hello", subtitle: "World", imageSystemName: "star")

    let state = HXCollectionState(
        sections: [section],
        itemsBySection: [section: [item]]
    )

    #expect(state.sections == [section])
    #expect(state[section] == [item])
}

@Test func actionIsHashableAndSendableFriendly() {
    let item = TestItem(id: 1, title: "Hello", subtitle: nil, imageSystemName: nil)
    let actions: Set<HXCollectionAction<TestItem>> = [
        .didSelect(item),
        .delete(item),
        .move(item, from: nil, to: HXCollectionIndexPath(item: 0, section: 0)),
        .reload
    ]

    #expect(actions.contains(.didSelect(item)))
    #expect(actions.contains(.delete(item)))
    #expect(actions.contains(.move(item, from: nil, to: HXCollectionIndexPath(item: 0, section: 0))))
    #expect(actions.contains(.reload))
}

@Test func defaultCellContentKeepsImageUIKitIndependent() {
    let item = TestItem(id: 1, title: "Title", subtitle: "Subtitle", imageSystemName: "photo")

    #expect(item.title == "Title")
    #expect(item.subtitle == "Subtitle")
    #expect(item.imageSystemName == "photo")
}

@Test func stateInsertAddsItemAtRequestedIndex() {
    let section = TestSection(id: "main")
    let first = TestItem(id: 1, title: "First", subtitle: nil, imageSystemName: nil)
    let second = TestItem(id: 2, title: "Second", subtitle: nil, imageSystemName: nil)
    var state = HXCollectionState<TestSection, TestItem>(sections: [section])

    state.insert(first, in: section)
    state.insert(second, in: section, at: 0)

    #expect(state[section] == [second, first])
}

@Test func stateDeleteRemovesExistingItem() {
    let section = TestSection(id: "main")
    let first = TestItem(id: 1, title: "First", subtitle: nil, imageSystemName: nil)
    let second = TestItem(id: 2, title: "Second", subtitle: nil, imageSystemName: nil)
    var state = HXCollectionState(
        sections: [section],
        itemsBySection: [section: [first, second]]
    )

    state.delete(first)

    #expect(state[section] == [second])
}

@Test func stateMoveSupportsCrossSectionDestination() {
    let firstSection = TestSection(id: "first")
    let secondSection = TestSection(id: "second")
    let first = TestItem(id: 1, title: "First", subtitle: nil, imageSystemName: nil)
    let second = TestItem(id: 2, title: "Second", subtitle: nil, imageSystemName: nil)
    var state = HXCollectionState(
        sections: [firstSection, secondSection],
        itemsBySection: [
            firstSection: [first],
            secondSection: [second]
        ]
    )

    state.move(first, to: HXCollectionIndexPath(item: 1, section: 1))

    #expect(state[firstSection].isEmpty)
    #expect(state[secondSection] == [second, first])
}

@Test func snapshotBuilderPreservesSectionAndItemOrder() {
    let firstSection = TestSection(id: "first")
    let secondSection = TestSection(id: "second")
    let first = TestItem(id: 1, title: "First", subtitle: nil, imageSystemName: nil)
    let second = TestItem(id: 2, title: "Second", subtitle: nil, imageSystemName: nil)
    let state = HXCollectionState(
        sections: [firstSection, secondSection],
        itemsBySection: [
            firstSection: [first],
            secondSection: [second]
        ]
    )

    let snapshot = HXSnapshotBuilder.makeSnapshot(from: state)

    #expect(snapshot.sectionIdentifiers == [firstSection, secondSection])
    #expect(snapshot.itemIdentifiers == [first, second])
}

@Test func layoutStylesExposeDefaultConfigurations() {
    #expect(HXCollectionLayoutStyle.allCases == [.list, .grid, .card])

    let grid = HXCollectionLayoutConfiguration.Grid(columns: 0)
    #expect(grid.columns == 1)

    let card = HXCollectionLayoutConfiguration.Card(groupWidthFraction: 2.0)
    #expect(card.groupWidthFraction == 1.0)
}
