import Testing
@testable import HXCollectionKit

@Test func collectionStateInitialStateIsCorrect() {
    let state = HXCollectionState<TestSection, TestItem>()

    #expect(state.sections.isEmpty)
    #expect(state.itemsBySection.isEmpty)
}

@Test func collectionStateStoresSectionsAndItems() {
    let section = TestSection(id: "main")
    let item = makeItem(1)
    let state = HXCollectionState(
        sections: [section],
        itemsBySection: [section: [item]]
    )

    #expect(state.sections == [section])
    #expect(state[section] == [item])
}

@Test func collectionStateInvalidMoveDoesNotCrashOrChangeOrder() {
    let section = TestSection(id: "main")
    let item = makeItem(1)
    var state = HXCollectionState(
        sections: [section],
        itemsBySection: [section: [item]]
    )

    state.move(item, to: HXCollectionIndexPath(item: 99, section: 99))

    #expect(state[section] == [item])
}
