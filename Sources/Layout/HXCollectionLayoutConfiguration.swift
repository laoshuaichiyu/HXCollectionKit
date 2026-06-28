import Foundation

/// UIKit-independent directional insets used by layout configuration.
public struct HXCollectionLayoutInsets: Hashable, Sendable {
    public var top: Double
    public var leading: Double
    public var bottom: Double
    public var trailing: Double

    public init(
        top: Double,
        leading: Double,
        bottom: Double,
        trailing: Double
    ) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    public static let zero = HXCollectionLayoutInsets(
        top: 0,
        leading: 0,
        bottom: 0,
        trailing: 0
    )
}

/// Configuration for HXCollectionKit's built-in compositional layouts.
///
/// The enum keeps section / group / item sizing decisions explicit per style
/// while staying Sendable and independent from UIKit symbols.
public enum HXCollectionLayoutConfiguration: Hashable, Sendable {
    case list(List)
    case grid(Grid)
    case card(Card)

    public struct List: Hashable, Sendable {
        public var rowHeight: Double
        public var interGroupSpacing: Double
        public var contentInsets: HXCollectionLayoutInsets
        public var showsSeparators: Bool

        public init(
            rowHeight: Double = 56,
            interGroupSpacing: Double = 0,
            contentInsets: HXCollectionLayoutInsets = .zero,
            showsSeparators: Bool = true
        ) {
            self.rowHeight = rowHeight
            self.interGroupSpacing = interGroupSpacing
            self.contentInsets = contentInsets
            self.showsSeparators = showsSeparators
        }
    }

    public struct Grid: Hashable, Sendable {
        public var columns: Int
        public var itemSpacing: Double
        public var rowSpacing: Double
        public var contentInsets: HXCollectionLayoutInsets
        public var itemHeight: Double

        public init(
            columns: Int = 2,
            itemSpacing: Double = 12,
            rowSpacing: Double = 12,
            contentInsets: HXCollectionLayoutInsets = HXCollectionLayoutInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
            itemHeight: Double = 96
        ) {
            self.columns = max(1, columns)
            self.itemSpacing = itemSpacing
            self.rowSpacing = rowSpacing
            self.contentInsets = contentInsets
            self.itemHeight = itemHeight
        }
    }

    public struct Card: Hashable, Sendable {
        public var groupWidthFraction: Double
        public var groupHeight: Double
        public var itemSpacing: Double
        public var contentInsets: HXCollectionLayoutInsets

        public init(
            groupWidthFraction: Double = 0.86,
            groupHeight: Double = 180,
            itemSpacing: Double = 12,
            contentInsets: HXCollectionLayoutInsets = HXCollectionLayoutInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        ) {
            self.groupWidthFraction = min(max(groupWidthFraction, 0.1), 1.0)
            self.groupHeight = groupHeight
            self.itemSpacing = itemSpacing
            self.contentInsets = contentInsets
        }
    }

    public static func `default`(
        for style: HXCollectionLayoutStyle
    ) -> HXCollectionLayoutConfiguration {
        switch style {
        case .list:
            return .list(List())
        case .grid:
            return .grid(Grid())
        case .card:
            return .card(Card())
        }
    }
}
