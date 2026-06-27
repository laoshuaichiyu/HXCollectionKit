@testable import HXCollectionKit

struct TestSection: HXSection {
    let id: String
}

struct TestItem: HXDefaultCellContent {
    let id: Int
    let title: String
    let subtitle: String?
    let imageSystemName: String?
}

func makeItem(
    _ id: Int,
    title: String? = nil
) -> TestItem {
    TestItem(
        id: id,
        title: title ?? "Item \(id)",
        subtitle: nil,
        imageSystemName: nil
    )
}

func assertSendable<T: Sendable>(_ value: T) {}

actor TestCollectionViewModel: HXCollectionViewModelProtocol {
    private var currentState: HXCollectionState<TestSection, TestItem>

    init(state: HXCollectionState<TestSection, TestItem>) {
        self.currentState = state
    }

    var state: HXCollectionState<TestSection, TestItem> {
        get async { currentState }
    }

    func send(_ action: HXCollectionAction<TestItem>) async {
        switch action {
        case .insert(after: let item):
            let inserted = makeItem(nextID(), title: "Inserted")
            if let item, let location = currentState.location(of: item) {
                currentState.insert(inserted, in: location.section, at: location.index + 1)
            } else {
                let section = currentState.sections.first ?? TestSection(id: "main")
                currentState.insert(inserted, in: section)
            }
        case .delete(let item), .didDelete(let item):
            currentState.delete(item)
        case .move(let item, from: _, to: let destination):
            currentState.move(item, to: destination)
        case .rename(let item):
            guard let location = currentState.location(of: item) else { return }
            let renamed = TestItem(
                id: item.id,
                title: "\(item.title) Renamed",
                subtitle: item.subtitle,
                imageSystemName: item.imageSystemName
            )
            currentState.itemsBySection[location.section]?[location.index] = renamed
        case .duplicate(let item):
            guard let location = currentState.location(of: item) else { return }
            let duplicate = TestItem(
                id: nextID(),
                title: "\(item.title) Copy",
                subtitle: item.subtitle,
                imageSystemName: item.imageSystemName
            )
            currentState.insert(duplicate, in: location.section, at: location.index + 1)
        case .reload,
             .didSelect,
             .didDeselect,
             .didMove,
             .willDisplay,
             .didEndDisplay,
             .prefetch:
            break
        }
    }

    private func nextID() -> Int {
        let maxID = currentState.itemsBySection.values.flatMap { $0 }.map(\.id).max() ?? 0
        return maxID + 1
    }
}
