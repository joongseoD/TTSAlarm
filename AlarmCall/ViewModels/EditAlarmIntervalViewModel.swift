//
//  EditAlarmIntervalViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import RxSwift
import RxCocoa

protocol EditAlarmIntervalViewModelDependency {
    var dataSource: EditViewModelDataSource<Int> { get }
}

final class EditAlarmIntervalViewModel: EditViewModelType, ViewModel {
    
    typealias Element = Int
    
    private let dependency: EditAlarmIntervalViewModelDependency
    
    var dataSource: EditViewModelDataSource<Element>
    
    var _values = BehaviorRelay<[WrappedItem<Element>]>(value: [])
    
    var _changedValues = PublishSubject<[Element]>()
    
    var selectedIndex: Binder<IndexPath> {
        return Binder<IndexPath>(self) { viewModel, indexPath in
            let wrappedItem = viewModel._values.value[indexPath.item]
            viewModel.changeValues([wrappedItem.item])
        }
    }
    
    var bag = DisposeBag()
    
    init(dependency: EditAlarmIntervalViewModelDependency) {
        self.dependency = dependency
        self.dataSource = dependency.dataSource
        
        bindDataSource()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
}
