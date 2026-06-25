import Foundation

/// Supported high-level compositional layout styles.
public enum HXCollectionLayoutStyle: String, CaseIterable, Hashable, Identifiable, Sendable {
    case list
    case grid
    case card

    public var id: String { rawValue }
}
