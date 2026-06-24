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
    let actions: Set<HXCollectionAction<TestItem>> = [.didSelect(item), .reload]

    #expect(actions.contains(.didSelect(item)))
    #expect(actions.contains(.reload))
}

@Test func defaultCellContentKeepsImageUIKitIndependent() {
    let item = TestItem(id: 1, title: "Title", subtitle: "Subtitle", imageSystemName: "photo")

    #expect(item.title == "Title")
    #expect(item.subtitle == "Subtitle")
    #expect(item.imageSystemName == "photo")
}
