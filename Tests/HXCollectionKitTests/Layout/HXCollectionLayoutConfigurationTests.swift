import Testing
@testable import HXCollectionKit

@Test func listLayoutConfigurationKeepsProvidedValues() {
    let insets = HXCollectionLayoutInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
    let config = HXCollectionLayoutConfiguration.List(
        rowHeight: 72,
        interGroupSpacing: 8,
        contentInsets: insets,
        showsSeparators: false
    )

    #expect(config.rowHeight == 72)
    #expect(config.interGroupSpacing == 8)
    #expect(config.contentInsets == insets)
    #expect(config.showsSeparators == false)
}

@Test func gridLayoutConfigurationKeepsSpacingInsetsAndColumnCount() {
    let insets = HXCollectionLayoutInsets(top: 10, leading: 11, bottom: 12, trailing: 13)
    let config = HXCollectionLayoutConfiguration.Grid(
        columns: 3,
        itemSpacing: 6,
        rowSpacing: 7,
        contentInsets: insets,
        itemHeight: 88
    )

    #expect(config.columns == 3)
    #expect(config.itemSpacing == 6)
    #expect(config.rowSpacing == 7)
    #expect(config.contentInsets == insets)
    #expect(config.itemHeight == 88)
}

@Test func cardLayoutConfigurationKeepsProvidedValues() {
    let insets = HXCollectionLayoutInsets(top: 4, leading: 5, bottom: 6, trailing: 7)
    let config = HXCollectionLayoutConfiguration.Card(
        groupWidthFraction: 0.7,
        groupHeight: 220,
        itemSpacing: 9,
        contentInsets: insets
    )

    #expect(config.groupWidthFraction == 0.7)
    #expect(config.groupHeight == 220)
    #expect(config.itemSpacing == 9)
    #expect(config.contentInsets == insets)
}

@Test func layoutStyleSwitchingDoesNotAffectState() {
    let section = TestSection(id: "main")
    let item = makeItem(1)
    let state = HXCollectionState(sections: [section], itemsBySection: [section: [item]])
    let styles = HXCollectionLayoutStyle.allCases

    #expect(styles == [.list, .grid, .card])
    #expect(state[section] == [item])
}

@Test func invalidGridColumnCountFallsBackToOne() {
    let config = HXCollectionLayoutConfiguration.Grid(columns: 0)

    #expect(config.columns == 1)
}

@Test func invalidCardWidthFractionIsClamped() {
    let tooSmall = HXCollectionLayoutConfiguration.Card(groupWidthFraction: -1)
    let tooLarge = HXCollectionLayoutConfiguration.Card(groupWidthFraction: 2)

    #expect(tooSmall.groupWidthFraction == 0.1)
    #expect(tooLarge.groupWidthFraction == 1.0)
}
