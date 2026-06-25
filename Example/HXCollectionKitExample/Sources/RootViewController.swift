import HXCollectionKit
import UIKit

@MainActor
final class RootViewController: UIViewController {
    private let viewModel = ExampleCollectionViewModel()
    private var currentLayoutStyle: HXCollectionLayoutStyle = .list

    private lazy var layoutControl: UISegmentedControl = {
        let control = UISegmentedControl(items: HXCollectionLayoutStyle.allCases.map(\.rawValue.capitalized))
        control.selectedSegmentIndex = HXCollectionLayoutStyle.allCases.firstIndex(of: currentLayoutStyle) ?? 0
        control.addTarget(self, action: #selector(layoutControlValueChanged), for: .valueChanged)
        return control
    }()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout(for: currentLayoutStyle)
    )

    private var dataSource: HXCollectionDataSource<ExampleSection, ExampleItem>?
    private var interactionCoordinator: HXCollectionInteractionCoordinator<ExampleSection, ExampleItem>?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "HXCollectionKit"
        view.backgroundColor = .systemBackground
        configureNavigationItem()
        configureCollectionView()
        bindViewModel()
    }

    private func configureNavigationItem() {
        navigationItem.titleView = layoutControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in
                Task { @MainActor in
                    await self?.send(.insert(after: nil))
                }
            }
        )
    }

    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let dataSource = HXCollectionDataSource<ExampleSection, ExampleItem>(collectionView: collectionView)
        self.dataSource = dataSource

        let interactionCoordinator = HXCollectionInteractionCoordinator<ExampleSection, ExampleItem>(
            collectionView: collectionView,
            itemResolver: { [weak dataSource] indexPath in
                dataSource?.itemIdentifier(for: indexPath)
            },
            actionHandler: { [weak self] action in
                await self?.send(action)
            }
        )
        interactionCoordinator.bind()
        self.interactionCoordinator = interactionCoordinator
    }

    private func bindViewModel() {
        Task { [weak self] in
            await self?.renderState(animatingDifferences: false)
        }
    }

    private func send(_ action: HXCollectionAction<ExampleItem>) async {
        await viewModel.send(action)

        if case .move = action {
            await renderState(animatingDifferences: false)
        } else {
            await renderState(animatingDifferences: true)
        }
    }

    private func renderState(animatingDifferences: Bool) async {
        let state = await viewModel.state
        dataSource?.apply(state: state, animatingDifferences: animatingDifferences)
    }

    @objc private func layoutControlValueChanged(_ sender: UISegmentedControl) {
        let styles = HXCollectionLayoutStyle.allCases
        guard styles.indices.contains(sender.selectedSegmentIndex) else {
            return
        }

        setLayoutStyle(styles[sender.selectedSegmentIndex], animated: true)
    }

    private func setLayoutStyle(
        _ style: HXCollectionLayoutStyle,
        animated: Bool
    ) {
        guard style != currentLayoutStyle else {
            return
        }

        currentLayoutStyle = style
        collectionView.setCollectionViewLayout(makeLayout(for: style), animated: animated)
    }

    private func makeLayout(for style: HXCollectionLayoutStyle) -> UICollectionViewCompositionalLayout {
        switch style {
        case .list:
            return HXCollectionLayoutFactory.makeListLayout { [weak self] indexPath in
                guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else {
                    return nil
                }

                let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                    Task { @MainActor in
                        await self?.send(.delete(item))
                        completion(true)
                    }
                }
                delete.image = UIImage(systemName: "trash")
                return UISwipeActionsConfiguration(actions: [delete])
            }
        case .grid, .card:
            // Standard compositional grid/card sections do not provide list-cell
            // trailing swipe APIs. Deletion for these layouts is available via
            // ContextMenu so the data flow remains the same.
            return HXCollectionLayoutFactory.makeLayout(style: style)
        }
    }
}
