import Foundation
import HXCollectionKit

struct ExampleSection: String, HXSection {
    case main

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
        let items = [
            ExampleItem(
                id: UUID(),
                title: "HXCollectionKit",
                subtitle: "Reusable DataSource + CellRegistration",
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
        ]

        self.currentState = HXCollectionState(
            sections: [.main],
            itemsBySection: [.main: items]
        )
    }

    var state: HXCollectionState<ExampleSection, ExampleItem> {
        get async { currentState }
    }

    func send(_ action: HXCollectionAction<ExampleItem>) async {
        switch action {
        case .reload:
            break
        default:
            break
        }
    }
}
