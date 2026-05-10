//
//  Coordinator.swift
//  homework4
//
//  Created by Максим  on 06.05.2026.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChildCoordinator<T: Coordinator>(ofType type: T.Type) {
        childCoordinators.removeAll { $0 is T }
    }
}
