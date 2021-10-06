//
//  ViewRouter.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import UIKit

protocol ViewControllerType where Self: UIViewController {
    
}
protocol ViewModelType {
    
}

enum Destination {
    case main
    case alarmDetail(id: String?)
    
    var viewController: ViewControllerType {
        switch self {
        case .main:
            let mainViewController = MainViewController()
            mainViewController.viewModel = viewModel as? MainViewModel
            return mainViewController
            
        case .alarmDetail:
            let detailVC = AlarmDetailViewController()
            detailVC.viewModel = viewModel as? AlarmDetailViewModel
            return detailVC
        }
    }
    
    private var viewModel: ViewModelType {
        switch self {
        case .main:
            return MainViewModel()
        case let .alarmDetail(id):
            return AlarmDetailViewModel(alarmId: id)
        }
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
