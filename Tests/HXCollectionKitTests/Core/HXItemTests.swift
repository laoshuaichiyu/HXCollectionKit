import Testing
@testable import HXCollectionKit

@Test func itemConformsToHashableIdentifiableAndSendable() {
    let item = makeItem(1)
    let duplicateIdentity = makeItem(1)
    let set: Set<TestItem> = [item, duplicateIdentity]

    assertSendable(item)
    #expect(item.id == 1)
    #expect(set.count == 1)
}

@Test func defaultCellContentExposesTextAndUIKitIndependentImageName() {
    let item = TestItem(id: 1, title: "Title", subtitle: "Subtitle", imageSystemName: "photo")

    #expect(item.title == "Title")
    #expect(item.subtitle == "Subtitle")
    #expect(item.imageSystemName == "photo")
}
