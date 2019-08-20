
import Foundation
import SceneKit

public extension SCNNode {
    
    /// Adds showing debug axes (local and pivot coordinate systems) to the node.
    ///
    /// - Parameter recursively: if it set to `true` then debug axes are added to each child nodes. Default value is `false`.
    public func addDebugAxes(recursively: Bool = false) {
        SCNNodeVisualDebugger.shared.addDebugAxes(to: self, recursively: recursively)
    }
    
    /// Removes showing debug axes (local and pivot coordinate systems) from the node.
    ///
    /// - Parameter recursively: if it set to `true` then debug axes are removed from each child nodes. Default value is `false`.
    public func removeDebugAxes(recursively: Bool = false) {
        SCNNodeVisualDebugger.shared.removeDebugAxes(from: self, recursively: recursively)
    }
    
    /// Checks if the node has debug axes.
    ///
    /// - Returns: `true` if the node has debug axes otherwise `false`.
    public func hasDebugAxes() -> Bool {
        return hasLocalDebugAxes && hasPivotDebugAxes
    }
}
