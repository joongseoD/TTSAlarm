//
//  EditAlarmIntervalViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import RxSwift
import RxCocoa

final class EditAlarmIntervalViewModel: EditViewModelType, ViewModelType {
    
    typealias Element = Int
    
    var dataSource: EditViewModelDataSource<Element>
    
    var _values = BehaviorRelay<[WrappedItem<Element>]>(value: [])
    
    var _changedValues = PublishSubject<[Element]>()
    
    var selectedIndex: Binder<IndexPath> {
        return Binder<IndexPath>(self) { viewModel, indexPath in
            Observable.just(indexPath.item)
                .withLatestFrom(viewModel._values) { selectedIndex, values -> WrappedItem<Element> in
                    return values[selectedIndex]
                }
                .subscribe(onNext: { wrappedItem in
                    viewModel.changeValues([wrappedItem.item])
                })
                .disposed(by: viewModel.bag)
        }
    }
    
    var bag = DisposeBag()
    
    init(dataSource: EditViewModelDataSource<Element>) {
        self.dataSource = dataSource
        
        bindDataSource()
    }
}
