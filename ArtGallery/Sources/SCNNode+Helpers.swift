
import Foundation
import SceneKit

extension SCNNode {
    var isDebugAxes: Bool {
        return self.name == CoordinateSystem.local ||
            self.name == CoordinateSystem.pivot ||
            self.name == CoordinateSystem.Axis.x ||
            self.name == CoordinateSystem.Axis.y ||
            self.name == CoordinateSystem.Axis.z
    }
    
    var hasLocalDebugAxes: Bool {
        return self.childNode(withName: CoordinateSystem.local, recursively: false) != nil
    }
    
    var hasPivotDebugAxes: Bool {
        return pivotAxes != nil
    }
    
    var pivotAxes: SCNNode? {
        return self.childNode(withName: CoordinateSystem.pivot, recursively: false)
    }
    
    var lengthOfTheGreatestSideOfNodeBox: Float {
        return self.geometry?.lengthOfTheGreatestSide ?? self.lengthOfTheGreatestSide
    }
}
