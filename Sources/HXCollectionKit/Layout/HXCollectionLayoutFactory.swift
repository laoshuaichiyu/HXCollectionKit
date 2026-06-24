#if canImport(UIKit)
import UIKit

/// Factory for UIKit compositional layouts used by HXCollectionKit.
public enum HXCollectionLayoutFactory {
    public static func makeLayout(
        style: HXCollectionLayoutStyle,
        configuration: HXCollectionLayoutConfiguration? = nil
    ) -> UICollectionViewCompositionalLayout {
        let resolvedConfiguration = configuration ?? .default(for: style)

        switch (style, resolvedConfiguration) {
        case (.list, .list(let listConfiguration)):
            return makeListLayout(configuration: listConfiguration)
        case (.grid, .grid(let gridConfiguration)):
            return makeGridLayout(configuration: gridConfiguration)
        case (.card, .card(let cardConfiguration)):
            return makeCardLayout(configuration: cardConfiguration)
        default:
            return makeLayout(style: style, configuration: .default(for: style))
        }
    }


    public static func makeListLayout(
        configuration: HXCollectionLayoutConfiguration.List = .init(),
        trailingSwipeActionsConfigurationProvider: @escaping UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider
    ) -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = configuration.showsSeparators
        listConfiguration.trailingSwipeActionsConfigurationProvider = trailingSwipeActionsConfigurationProvider

        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        layout.configuration.contentInsetsReference = .automatic
        return layout
    }

    private static func makeListLayout(
        configuration: HXCollectionLayoutConfiguration.List
    ) -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(CGFloat(configuration.rowHeight))
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(CGFloat(configuration.rowHeight))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = CGFloat(configuration.interGroupSpacing)
        section.contentInsets = configuration.contentInsets.directionalInsets

        return UICollectionViewCompositionalLayout(section: section)
    }

    private static func makeGridLayout(
        configuration: HXCollectionLayoutConfiguration.Grid
    ) -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(CGFloat(configuration.itemHeight))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: configuration.columns
        )
        group.interItemSpacing = .fixed(CGFloat(configuration.itemSpacing))

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = CGFloat(configuration.rowSpacing)
        section.contentInsets = configuration.contentInsets.directionalInsets

        return UICollectionViewCompositionalLayout(section: section)
    }

    private static func makeCardLayout(
        configuration: HXCollectionLayoutConfiguration.Card
    ) -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(CGFloat(configuration.groupWidthFraction)),
            heightDimension: .absolute(CGFloat(configuration.groupHeight))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = CGFloat(configuration.itemSpacing)
        section.contentInsets = configuration.contentInsets.directionalInsets

        return UICollectionViewCompositionalLayout(section: section)
    }
}

private extension HXCollectionLayoutInsets {
    var directionalInsets: NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(
            top: CGFloat(top),
            leading: CGFloat(leading),
            bottom: CGFloat(bottom),
            trailing: CGFloat(trailing)
        )
    }
}
#endif
