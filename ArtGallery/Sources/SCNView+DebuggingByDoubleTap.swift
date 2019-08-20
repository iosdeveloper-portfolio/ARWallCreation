
import Foundation
import SceneKit

public extension SCNView {
    public var enableDebugAxesByDoubleTap: Bool {
        get {
            return SCNNodeVisualDebugger.shared.enableDebugAxesByDoubleTap
        }
        set(enable) {
            SCNNodeVisualDebugger.shared.enableDebugAxesByDoubleTap = enable
            if enable {
                SCNNodeVisualDebugger.shared.addDoubleTapGestureRecognizer(to: self)
            } else {
                SCNNodeVisualDebugger.shared.removeDoubleTapGestureRecognizer(from: self)
            }
        }
    }
}
