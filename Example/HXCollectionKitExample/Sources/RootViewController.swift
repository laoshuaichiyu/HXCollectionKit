import HXCollectionKit
import UIKit

@MainActor
final class RootViewController: UIViewController {
    private let viewModel = ExampleCollectionViewModel()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: Self.makeLayout()
    )

    private var dataSource: HXCollectionDataSource<ExampleSection, ExampleItem>?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "HXCollectionKit"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        bindViewModel()
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

        dataSource = HXCollectionDataSource(collectionView: collectionView)
    }

    private func bindViewModel() {
        Task { [weak self] in
            guard let self else { return }

            let state = await viewModel.state
            dataSource?.apply(state: state, animatingDifferences: false)
        }
    }

    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = true
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}
