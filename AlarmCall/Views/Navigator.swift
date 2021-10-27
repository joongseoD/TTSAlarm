//
//  ViewRouter.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import UIKit

protocol ViewController: UIViewController { }

protocol ViewModel: AnyObject { }

enum Destination {
    case main(component: MainViewModelDependency)
    case alarmDetail(component: AlarmDetailViewModelDependency)
    case editRepeatDays(component: EditAlarmRepeatDaysViewModelDependency)
    case editInterval(component: EditAlarmIntervalViewModelDependency)
    case editComment(component: EditAlarmCommentViewModelDependency)
    
    var viewController: ViewController {
        var viewController: ViewController
        switch self {
        case let .main(component):
            viewController = MainViewController(viewModel: .init(dependency: component))
        case let .alarmDetail(component):
            viewController = AlarmDetailViewController(viewModel: .init(dependency: component))
        case let .editRepeatDays(component):
            viewController = EditAlarmRepeatDaysViewController(viewModel: .init(dependency: component))
        case let .editInterval(component):
            viewController = EditAlarmIntervalViewController(viewModel: .init(dependency: component))
        case let .editComment(component):
            viewController = EditAlarmCommentViewController(viewModel: .init(dependency: component))
        }
        
        return viewController
    }
}

enum NavigatorOperation {
    case root
    case push
    case present
}

extension UINavigationController {
    func transition(to destination: Destination, operation: NavigatorOperation = .push, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch operation {
            case .root: self.root(destination.viewController, completion: completion)
            case .push: self.push(to: destination.viewController, completion: completion)
            case .present: self.present(to: destination.viewController, completion: completion)
            }
        }
    }
    
    private func root(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewControllers = [viewController]
        completion?()
    }
    
    private func push(to viewController: UIViewController, completion: (() -> Void)?) {
        pushViewController(viewController, animated: true)
        completion?()
    }
    
    private func present(to viewController: UIViewController, completion: (() -> Void)?) {
        present(viewController, animated: true, completion: completion)
    }
}
