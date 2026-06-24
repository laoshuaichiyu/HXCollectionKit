import Foundation
import HXCollectionKit

struct ExampleSection: String, HXSection {
    case main
    case secondary

    var id: String { rawValue }
}

struct ExampleItem: HXDefaultCellContent {
    let id: UUID
    let title: String
    let subtitle: String?
    let imageSystemName: String?
}

actor ExampleCollectionViewModel: HXCollectionViewModelProtocol {
    private var currentState: HXCollectionState<ExampleSection, ExampleItem>

    init() {
        self.currentState = HXCollectionState(
            sections: [.main, .secondary],
            itemsBySection: [
                .main: [
                    ExampleItem(
                        id: UUID(),
                        title: "HXCollectionKit",
                        subtitle: "Drag, menu, swipe, and diffable rendering",
                        imageSystemName: "square.grid.2x2"
                    ),
                    ExampleItem(
                        id: UUID(),
                        title: "Swift 6 Ready",
                        subtitle: "State stays Sendable and UIKit-independent",
                        imageSystemName: "swift"
                    ),
                    ExampleItem(
                        id: UUID(),
                        title: "Diffable Snapshot",
                        subtitle: "ViewController binds state to DataSource",
                        imageSystemName: "arrow.triangle.2.circlepath"
                    )
                ],
                .secondary: [
                    ExampleItem(
                        id: UUID(),
                        title: "Drag Across Sections",
                        subtitle: "Drop into another section to move in state",
                        imageSystemName: "arrow.up.and.down.and.arrow.left.and.right"
                    ),
                    ExampleItem(
                        id: UUID(),
                        title: "Context Menu",
                        subtitle: "Delete, insert, copy, and rename",
                        imageSystemName: "contextualmenu.and.cursorarrow"
                    )
                ]
            ]
        )
    }

    var state: HXCollectionState<ExampleSection, ExampleItem> {
        get async { currentState }
    }

    func send(_ action: HXCollectionAction<ExampleItem>) async {
        switch action {
        case .delete(let item), .didDelete(let item):
            delete(item)
        case .insert(after: let item):
            insert(after: item)
        case .duplicate(let item):
            duplicate(item)
        case .rename(let item):
            rename(item)
        case .move(let item, from: _, to: let destination):
            move(item, to: destination)
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

    private func delete(_ item: ExampleItem) {
        guard let location = location(of: item) else { return }
        currentState.itemsBySection[location.section]?.remove(at: location.index)
    }

    private func insert(after item: ExampleItem?) {
        let newItem = ExampleItem(
            id: UUID(),
            title: "Inserted Item",
            subtitle: "Created by ViewModel action",
            imageSystemName: "plus.circle"
        )

        guard let item, let location = location(of: item) else {
            currentState.itemsBySection[.main, default: []].append(newItem)
            return
        }

        currentState.itemsBySection[location.section, default: []].insert(
            newItem,
            at: location.index + 1
        )
    }

    private func duplicate(_ item: ExampleItem) {
        guard let location = location(of: item) else { return }
        let copiedItem = ExampleItem(
            id: UUID(),
            title: "\(item.title) Copy",
            subtitle: item.subtitle,
            imageSystemName: item.imageSystemName
        )
        currentState.itemsBySection[location.section, default: []].insert(
            copiedItem,
            at: location.index + 1
        )
    }

    private func rename(_ item: ExampleItem) {
        guard let location = location(of: item) else { return }
        let renamedItem = ExampleItem(
            id: item.id,
            title: "\(item.title) Renamed",
            subtitle: item.subtitle,
            imageSystemName: item.imageSystemName
        )
        currentState.itemsBySection[location.section]?[location.index] = renamedItem
    }

    private func move(
        _ item: ExampleItem,
        to destination: HXCollectionIndexPath
    ) {
        guard let source = location(of: item),
              currentState.sections.indices.contains(destination.section) else {
            return
        }

        let destinationSection = currentState.sections[destination.section]
        var sourceItems = currentState.itemsBySection[source.section, default: []]
        sourceItems.remove(at: source.index)
        currentState.itemsBySection[source.section] = sourceItems

        var destinationItems = currentState.itemsBySection[destinationSection, default: []]
        let adjustedDestinationIndex: Int
        if source.section == destinationSection, source.index < destination.item {
            adjustedDestinationIndex = max(0, destination.item - 1)
        } else {
            adjustedDestinationIndex = destination.item
        }
        let targetIndex = min(max(0, adjustedDestinationIndex), destinationItems.count)
        destinationItems.insert(item, at: targetIndex)
        currentState.itemsBySection[destinationSection] = destinationItems
    }

    private func location(
        of item: ExampleItem
    ) -> (section: ExampleSection, index: Int)? {
        for section in currentState.sections {
            guard let index = currentState.itemsBySection[section]?.firstIndex(of: item) else {
                continue
            }
            return (section, index)
        }
        return nil
    }
}
