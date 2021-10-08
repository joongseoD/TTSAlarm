//
//  MainViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import RxSwift
import RxCocoa

final class MainViewModel: ViewModelType {
    
    private let service: AlarmServiging
    private let _alarmSectionModel = BehaviorSubject<[AlarmSectionModel]>(value: [])
    private let _alarmList = BehaviorRelay<[Alarm]>(value: [])
    private let _message = PublishSubject<String>()
    private let _selectedIndex = PublishSubject<Int>()
    private let _refresh = PublishSubject<Void>()
    
    lazy var selectedAlarm: Driver<Alarm> = {
        return _selectedIndex
            .withLatestFrom(_alarmList) { index, list -> Alarm? in
                guard list.indices.contains(index) else { return nil }
                return list[index]
            }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
    }()
    
    lazy var refresh: (() -> Void)? = { [weak self] in
        return {
            self?._refresh.onNext(())
        }
    }()
    
    private var disposeBag = DisposeBag()
    
    init(service: AlarmServiging = AlarmService()) {
        self.service = service
        
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
}
