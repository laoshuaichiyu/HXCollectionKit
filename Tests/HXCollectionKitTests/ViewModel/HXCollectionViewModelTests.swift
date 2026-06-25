import Testing
@testable import HXCollectionKit

@Test func viewModelInitialItemsAreCorrect() async {
    let section = TestSection(id: "main")
    let items = [makeItem(1), makeItem(2)]
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: items])
    )

    let state = await viewModel.state

    #expect(state.sections == [section])
    #expect(state[section] == items)
}

@Test func viewModelActionChangesOnlyStateWithoutUICollectionView() async {
    let section = TestSection(id: "main")
    let item = makeItem(1)
    let viewModel = TestCollectionViewModel(
        state: HXCollectionState(sections: [section], itemsBySection: [section: [item]])
    )

    await viewModel.send(.delete(item))
    let state = await viewModel.state

    #expect(state[section].isEmpty)
}
