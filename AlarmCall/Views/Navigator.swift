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
    case alarmDetail(id: String?, completion: (() -> Void)?)
    case editRepeatDays(dataSource: EditViewModelDataSource<DayOfWeek>)
    case editInterval(dataSource: EditViewModelDataSource<Int>)
    case editComment(previous: String, completion: ((String) -> Void)?)
    
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
            
        case .editRepeatDays:
            let editCommentVC = EditAlarmRepeatDaysViewController()
            editCommentVC.viewModel = viewModel as? EditAlarmRepeatDaysViewModel
            return editCommentVC
        
        case .editInterval:
            let editIntervalVC = EditAlarmIntervalViewController()
            editIntervalVC.viewModel = viewModel as? EditAlarmIntervalViewModel
            return editIntervalVC
        
        case .editComment:
            let editCommentVC = EditAlarmCommentViewController()
            editCommentVC.viewModel = viewModel as? EditAlarmCommentViewModel
            return editCommentVC
        }
    }
    
    private var viewModel: ViewModelType {
        switch self {
        case .main:
            return MainViewModel()
        case let .alarmDetail(id, completion):
            return AlarmDetailViewModel(alarmId: id, completion: completion)
        case let .editRepeatDays(dataSource):
            return EditAlarmRepeatDaysViewModel(dataSource: dataSource)
        case let .editInterval(dataSource):
            return EditAlarmIntervalViewModel(dataSource: dataSource)
        case let .editComment(previous, completion):
            return EditAlarmCommentViewModel(previous: previous, completion: completion)
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
