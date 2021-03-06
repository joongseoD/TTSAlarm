//
//  EditViewModelType.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import RxSwift
import RxCocoa

protocol EditViewModelType: ViewModel {
    associatedtype Element: Equatable

    var dataSource: EditViewModelDataSource<Element> { get set }
    
    var _values: BehaviorRelay<[SelectableItem<Element>]> { get set }
    
    var _changedValues: PublishSubject<[Element]> { get set }
    
    var bag: DisposeBag { get set }
    
    func bindDataSource()
    
    func changeValues(_ values: [Element])
}

extension EditViewModelType {
    func bindDataSource() {
        Observable.merge(.just(dataSource.previousValues), _changedValues.map { Optional($0) })
            .compactMap { [weak self] selectedValues -> [SelectableItem<Element>] in
                guard let self = self else { return [] }
                return self.dataSource.values.map { item in
                    let isContains = selectedValues?.contains(item) ?? false
                    return SelectableItem(item: item, isSelected: isContains)
                }
            }
            .bind(to: _values)
            .disposed(by: bag)
        
        _changedValues
            .subscribe(onNext: { [weak self] in
                self?.dataSource.changeValues?($0)
            })
            .disposed(by: bag)
    }
    
    var items: Driver<[SelectableItem<Element>]> {
        return _values.asDriver()
    }
    
    func changeValues(_ values: [Element]) {
        _changedValues.onNext(values)
    }
}

struct SelectableItem<T> {
    let item: T
    var isSelected: Bool = false
}
