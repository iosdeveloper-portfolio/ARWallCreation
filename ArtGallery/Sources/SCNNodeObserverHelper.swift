
import Foundation
import SceneKit

//MARK: SCNNodeObserverHelperDelegate
protocol SCNNodeObserverHelperDelegate: class {
    func nodeObserverHelperDelegate(_ helper: SCNNodeObserverHelper, didNodePivotChange node: SCNNode)
}


//MARK: SCNNodeObserverHelper
protocol SCNNodeObserverHelper: class  {
    weak var delegate: SCNNodeObserverHelperDelegate? { get set }
    func addObserver(to node: SCNNode)
    func removeObserver(from node: SCNNode)
    func removeAllObservers()
}

struct SCNNodeObserverHelperProvider {
    static func make() -> SCNNodeObserverHelper {
// FIXME: Make this available when Xcode 9 has stable version
//        #if swift(>=4.0)
//            return IOS11SCNNodeObserverHelper()
//        #endif
        
        return PreIOS11SCNNodeObserverHelper()
    }
}

// FIXME: Make this available when Xcode 9 has stable version
////MARK: IOS11SCNNodeObserverHelper
//@available(swift 4.0)
//fileprivate class IOS11SCNNodeObserverHelper: NSObject, SCNNodeObserverHelper {
//    var delegate: SCNNodeObserverHelperDelegate?
//    
//    private var observations = [SCNNode: NSKeyValueObservation]()
//    
//    func addObserver(to node: SCNNode) {
//        let observation = node.observe(\.pivot) { [weak self] node, change in
//            guard let strongSelf = self else { return }
//            strongSelf.delegate?.nodeObserverHelperDelegate(strongSelf, didNodePivotChange: node)
//        }
//        observations[node] = observation
//    }
//    
//    func removeObserver(from node: SCNNode) {
//        if let existingObservation = observations.removeValue(forKey: node) {
//            existingObservation.invalidate()
//        }
//    }
//    
//    func removeAllObservers() {
//        observations.values.forEach { $0.invalidate() }
//        observations.removeAll()
//    }
//}


//MARK: PreIOS11SCNNodeObserverHelper
fileprivate class PreIOS11SCNNodeObserverHelper: NSObject, SCNNodeObserverHelper {
    
    var delegate: SCNNodeObserverHelperDelegate?
    
    private var observedNodes = [SCNNode]()
    
    func addObserver(to node: SCNNode) {
        node.addObserver(self, forKeyPath: #keyPath(SCNNode.pivot), options: [.new], context: nil)
    }
    
    func removeObserver(from node: SCNNode) {
        if let index = observedNodes.index(of: node) {
            let node = observedNodes.remove(at: index)
            node.removeObserver(self, forKeyPath: #keyPath(SCNNode.pivot), context: nil)
        }
    }
    
    func removeAllObservers() {
        observedNodes.forEach { $0.removeObserver(self, forKeyPath: #keyPath(SCNNode.pivot), context: nil) }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(SCNNode.pivot),
            let node = object as? SCNNode else { return }
        delegate?.nodeObserverHelperDelegate(self, didNodePivotChange: node)
    }
}
