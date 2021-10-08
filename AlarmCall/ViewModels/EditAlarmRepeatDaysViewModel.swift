//
//  EditAlarmCommentVIewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import RxSwift
import RxCocoa

final class EditAlarmRepeatDaysViewModel: EditViewModelType, ViewModelType {
    
    typealias Element = DayOfWeek
    
    var dataSource: EditViewModelDataSource<Element>
    
    var _values = BehaviorRelay<[WrappedItem<Element>]>(value: [])
    
    var _changedValues = PublishSubject<[Element]>()
    
    private let selectedElements: BehaviorRelay<[Element]>
    
    var selectedIndex: Binder<IndexPath> {
        return Binder<IndexPath>(self) { viewModel, indexPath in
            Observable.just(indexPath.item)
                .withLatestFrom(viewModel._values) { selectedIndex, values -> WrappedItem<Element> in
                    return values[selectedIndex]
                }
                .withLatestFrom(viewModel.selectedElements) { wrappedItem, selectedValues -> [Element] in
                    var previousValues = selectedValues
                    if let index = previousValues.firstIndex(where: { $0 == wrappedItem.item }) {
                        previousValues.remove(at: index)
                    } else {
                        previousValues.append(wrappedItem.item)
                    }
                    return previousValues
                }
                .subscribe(onNext: { items in
                    viewModel.selectedElements.accept(items)
                    viewModel.changeValues(items)
                })
                .disposed(by: viewModel.bag)
        }
    }
    
    var bag = DisposeBag()
    
    init(dataSource: EditViewModelDataSource<Element>) {
        self.dataSource = dataSource
        self.selectedElements = BehaviorRelay<[Element]>(value: dataSource.previousValues ?? [])
        bindDataSource()
    }
}
