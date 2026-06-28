import Foundation

/// Base contract for collection sections used by HXCollectionKit.
///
/// Sections model diffable section identity and remain Sendable so state can
/// cross concurrency domains without UIKit coupling.
public protocol HXSection: Hashable, Identifiable, Sendable where ID: Hashable & Sendable {}
