import Foundation

/// Builds the framework's unified diffable snapshot from UI-independent state.
public enum HXSnapshotBuilder {
    public static func makeSnapshot<Section: HXSection, Item: HXItem>(
        from state: HXCollectionState<Section, Item>
    ) -> HXCollectionSnapshot<Section, Item> {
        var snapshot = HXCollectionSnapshot<Section, Item>()
        snapshot.appendSections(state.sections)

        for section in state.sections {
            snapshot.appendItems(state[section], toSection: section)
        }

        return snapshot
    }
}
