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
        collectionViewLayout: HXCollectionLayoutFactory.makeLayout(style: currentLayoutStyle)
    )

    private var dataSource: HXCollectionDataSource<ExampleSection, ExampleItem>?

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
        let layout = HXCollectionLayoutFactory.makeLayout(style: style)
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
}
