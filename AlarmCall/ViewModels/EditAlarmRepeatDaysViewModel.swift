//
//  EditAlarmCommentVIewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import RxSwift
import RxCocoa

protocol EditAlarmRepeatDaysViewModelDependency {
    var dataSource: EditViewModelDataSource<DayOfWeek> { get }
}

final class EditAlarmRepeatDaysViewModel: EditViewModelType {
    
    typealias Element = DayOfWeek
    
    var dataSource: EditViewModelDataSource<Element>
    
    var _values = BehaviorRelay<[WrappedItem<Element>]>(value: [])
    
    var _changedValues = PublishSubject<[Element]>()
    
    private let selectedElements: BehaviorRelay<[Element]>
    
    private let dependency: EditAlarmRepeatDaysViewModelDependency
    
    var selectedIndex: Binder<IndexPath> {
        return Binder<IndexPath>(self) { viewModel, indexPath in
            let wrappedItem = viewModel._values.value[indexPath.item]
            var previousValues = viewModel.selectedElements.value
            if let index = previousValues.firstIndex(where: { $0 == wrappedItem.item }) {
                previousValues.remove(at: index)
            } else {
                previousValues.append(wrappedItem.item)
            }
            
            viewModel.selectedElements.accept(previousValues)
            viewModel.changeValues(previousValues)
        }
    }
    
    var bag = DisposeBag()
    
    init(dependency: EditAlarmRepeatDaysViewModelDependency) {
        self.dependency = dependency
        self.dataSource = dependency.dataSource
        self.selectedElements = BehaviorRelay<[Element]>(value: dataSource.previousValues ?? [])
        bindDataSource()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
}
