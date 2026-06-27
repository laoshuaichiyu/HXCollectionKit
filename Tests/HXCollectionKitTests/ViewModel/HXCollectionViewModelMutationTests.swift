import Testing
@testable import HXCollectionKit

@Test func viewModelInsertsItemAfterAnchor() async {
    let section = TestSection(id: "main")
    let first = makeItem(1)
    let second = makeItem(2)
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [first, second]])
    )

    await viewModel.send(.insert(after: first))
    let items = await viewModel.state[section]

    #expect(items.map(\.title) == ["Item 1", "Inserted", "Item 2"])
}

@Test func viewModelDeletesItem() async {
    let section = TestSection(id: "main")
    let first = makeItem(1)
    let second = makeItem(2)
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [first, second]])
    )

    await viewModel.send(.delete(first))
    let items = await viewModel.state[section]

    #expect(items == [second])
}

@Test func viewModelMovesItemAndKeepsOrder() async {
    let section = TestSection(id: "main")
    let first = makeItem(1)
    let second = makeItem(2)
    let third = makeItem(3)
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [first, second, third]])
    )

    await viewModel.send(.move(first, from: HXCollectionIndexPath(item: 0, section: 0), to: HXCollectionIndexPath(item: 2, section: 0)))
    let items = await viewModel.state[section]

    #expect(items == [second, first, third])
}

@Test func viewModelRenamesItem() async {
    let section = TestSection(id: "main")
    let item = makeItem(1, title: "Original")
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [item]])
    )

    await viewModel.send(.rename(item))
    let renamed = await viewModel.state[section].first

    #expect(renamed?.id == item.id)
    #expect(renamed?.title == "Original Renamed")
}

@Test func viewModelDuplicatesItem() async {
    let section = TestSection(id: "main")
    let item = makeItem(1, title: "Original")
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [item]])
    )

    await viewModel.send(.duplicate(item))
    let items = await viewModel.state[section]

    #expect(items.count == 2)
    #expect(items.map(\.title) == ["Original", "Original Copy"])
}

@Test func viewModelHandlesEmptyStateInsert() async {
    let viewModel = TestCollectionViewModel(state: HXCollectionState())

    await viewModel.send(.insert(after: nil))
    let state = await viewModel.state

    #expect(state.sections == [TestSection(id: "main")])
    #expect(state[TestSection(id: "main")].map(\.title) == ["Inserted"])
}

@Test func viewModelInvalidIndexDoesNotCrash() async {
    let section = TestSection(id: "main")
    let item = makeItem(1)
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [item]])
    )

    await viewModel.send(.move(item, from: nil, to: HXCollectionIndexPath(item: 0, section: 10)))
    let items = await viewModel.state[section]

    #expect(items == [item])
}
