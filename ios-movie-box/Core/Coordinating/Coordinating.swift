protocol Coordinating: AnyObject {
    var parent: Coordinating? { get set }
    var childCoordinators: [Coordinating] { get set }

    func start()
    func childDidFinish(_ child: Coordinating)
}

extension Coordinating {
    func addChild(_ newChild: Coordinating, removeDuplicates: Bool = false) {
        if removeDuplicates {
            childCoordinators.removeAll { existingChild in
                type(of: existingChild) == type(of: newChild)
            }
        }
        childCoordinators.append(newChild)
    }
    
    func removeChild(_ child: Coordinating) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
        }
    }

    func childDidFinish(_ child: Coordinating) {
        removeChild(child)
    }
}
