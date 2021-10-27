//
//  MainViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import RxSwift
import RxCocoa

protocol MainViewModelDependency: AnyObject {
    var servicing: AlarmServiging { get }
}

final class RootComponent: MainViewModelDependency {
    var servicing: AlarmServiging
    
    init(servicing: AlarmServiging) {
        self.servicing = servicing
    }
}

final class MainComponent: AlarmDetailViewModelDependency {
    var servicing: AlarmServiging
    var alarmId: String?
    var editCompletion: (() -> Void)?

    init(servicing: AlarmServiging, alarmId: String?, editCompletion: (() -> Void)?) {
        self.servicing = servicing
        self.alarmId = alarmId
        self.editCompletion = editCompletion
    }
}

final class MainViewModel: ViewModel {
    private let service: AlarmServiging
    private let _alarmSectionModel = BehaviorSubject<[AlarmSectionModel]>(value: [])
    private let _alarmList = BehaviorRelay<[Alarm]>(value: [])
    private let _message = PublishSubject<String>()
    private let _selectedIndex = PublishSubject<Int>()
    private let _refresh = PublishSubject<Void>()
    private let _addNewAlarm = PublishSubject<Void>()
    
    lazy var detailComponent: Driver<AlarmDetailViewModelDependency> = {
        let selectedAlarm = _selectedIndex
            .withLatestFrom(_alarmList) { index, list -> Alarm? in
                guard list.indices.contains(index) else { return nil }
                return list[index]
            }
            
        let moveToNewAlarm = _addNewAlarm.map { Optional<Alarm>(nil) }
            
        return Observable.merge(selectedAlarm, moveToNewAlarm)
            .map {
                MainComponent(servicing: AlarmService(), alarmId: $0?.id) { [weak self] in
                    self?._refresh.onNext(())
                }
            }
            .asDriver { _ in
                return .empty()
            }
    }()
    
    lazy var refresh: (() -> Void)? = { [weak self] in
        return {
            self?._refresh.onNext(())
        }
    }()
    
    private var disposeBag = DisposeBag()
    private let dependency: MainViewModelDependency
    
    init(dependency: MainViewModelDependency) {
        self.dependency = dependency
        self.service = dependency.servicing
        
        setUp()
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    private func setUp() {
        Observable.merge(Observable.just(()), _refresh)
            .flatMap { [weak self] _ -> Observable<[Alarm]> in
                guard let self = self else { return .empty() }
                return self.service.alarmList()
            }
            .bind(to: _alarmList)
            .disposed(by: disposeBag)
        
        _alarmList
            .map { alarms in
                let models = alarms.map { AlarmCellModel(model: $0) }
                return [AlarmSectionModel(items: models)]
            }
            .bind(to: _alarmSectionModel)
            .disposed(by: disposeBag)
    }
}

//MARK: - Output Interface
extension MainViewModel {
    var alarmSectionModel: Driver<[AlarmSectionModel]> {
        return _alarmSectionModel.asDriver(onErrorJustReturn: [])
    }
    
    var message: Driver<String> {
        return _message.asDriver(onErrorJustReturn: "")
    }
}

//MARK: - Input Interface
extension MainViewModel {
    func toggle(_ alarmId: String, isOn: Bool) {
        Observable.just(alarmId)
            .withLatestFrom(_alarmList) { alarmId, alarmList in
                return alarmList.first(where: { $0.id == alarmId })
            }
            .compactMap { alarm -> Alarm? in
                var updateAlarm = alarm
                updateAlarm?.enable = isOn
                return updateAlarm
            }
            .flatMap { [weak self] alarm -> Observable<Alarm?> in
                guard let self = self else { return .empty() }
                return self.service.update(alarm, id: alarm.id)
                    .map { _ in alarm }
                    .catch { [weak self] error in
                        guard let serviceError = error as? AlarmServiceError else { return .just(nil) }
                        self?._message.onNext(serviceError.description)
                        return .just(nil)
                    }
            }
            .subscribe(onNext: { [weak self] update in
                guard let self = self,
                      let update = update else { return }
                var list = self._alarmList.value
                guard let index = list.firstIndex(where: { $0.id == update.id }) else { return }
                list.remove(at: index)
                list.insert(update, at: index)
            })
            .disposed(by: disposeBag)
    }
    
    var selectedIndex: Binder<IndexPath> {
        return Binder(self) { viewModel, indexPath in
            viewModel._selectedIndex.onNext(indexPath.row)
        }
    }
    
    var addAlarmButtonTapped: Binder<Void> {
        return Binder(self) { viewModel, _ in
            viewModel._addNewAlarm.onNext(())
        }
    }
}
