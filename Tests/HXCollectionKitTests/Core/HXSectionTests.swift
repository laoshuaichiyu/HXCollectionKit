import Testing
@testable import HXCollectionKit

@Test func sectionConformsToHashableIdentifiableAndSendable() {
    let section = TestSection(id: "main")
    let duplicateIdentity = TestSection(id: "main")
    let set: Set<TestSection> = [section, duplicateIdentity]

    assertSendable(section)
    #expect(section.id == "main")
    #expect(set.count == 1)
}
