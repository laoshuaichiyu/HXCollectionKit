import Foundation

/// MVVM boundary for collection-backed screens.
///
/// Implementations may perform work off the main actor. Rendering remains the
/// responsibility of the coordinator layer, which consumes the produced state
/// and snapshots.
public protocol HXCollectionViewModelProtocol {
    associatedtype Section: HXSection
    associatedtype Item: HXItem

    var state: HXCollectionState<Section, Item> { get }

    func send(_ action: HXCollectionAction<Item>)
}
