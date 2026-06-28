import Foundation

/// Content contract used by HXCollectionKit's built-in list cell.
///
/// The optional image is represented by a system image name instead of UIImage
/// so the model stays Sendable and UIKit-independent.
public protocol HXDefaultCellContent: HXItem {
    var title: String { get }
    var subtitle: String? { get }
    var imageSystemName: String? { get }
}
