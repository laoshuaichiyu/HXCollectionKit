import Foundation

/// Base contract for collection items used by HXCollectionKit.
///
/// Items are intentionally not isolated to the main actor so they can be
/// produced by view models, repositories, and background tasks safely under
/// Swift 6 strict concurrency.
public protocol HXItem: Hashable, Identifiable, Sendable where ID: Hashable & Sendable {}
