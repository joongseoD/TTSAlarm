//
//  AlarmDetailViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import RxSwift
import RxCocoa

final class AlarmDetailViewModel: ViewModelType {
    private let service: AlarmServiging
    private let _sectionModels = BehaviorRelay<[AlarmDetailSectionModel]>(value: [])
    var sectionModels: Driver<[AlarmDetailSectionModel]> {
        return _sectionModels.asDriver()
    }
    
    private let _currentAlarm = PublishSubject<Alarm>()
    var currentAlarm: Driver<Alarm> {
        return _currentAlarm.asDriver(onErrorJustReturn: defaultAlarm)
    }
    
    private var defaultAlarm: Alarm {
        Alarm(comment: "Alarm", wakeUpDate: Date(), deadlineDate: nil, notificationIntervalMinute: nil, soundFileName: nil, repeatDays: nil, enable: false)
    }
    
    private let _toggleDeadline = BehaviorRelay<Bool>(value: false)
    
    private var bag = DisposeBag()
    
    init(service: AlarmServiging = AlarmService(), alarmId: String?) {
        self.service = service
        
        setUp()
        setUpCurrentAlarm(alarmId)
    }
    
    private func setUpCurrentAlarm(_ alarmId: String?) {
        if let alarmId = alarmId {
            service.alarm(with: alarmId)
                .catch { [weak self] error in
                    guard let self = self else { return .empty() }
                    return .just(self.defaultAlarm)
                }
                .subscribe(onNext: { [weak self] alarm in
                    self?._currentAlarm.onNext(alarm)
                    self?._toggleDeadline.accept(alarm.deadlineDate != nil)
                })
                .disposed(by: bag)
        } else {
            _currentAlarm.onNext(defaultAlarm)
        }
    }
    
    private func setUp() {
        Observable.combineLatest(_currentAlarm, _toggleDeadline)
            .map { alarm, toggle -> [AlarmDetailSectionModel] in
                let deadlineSectionItems: [AlarmDetailSection] = toggle ? [.deadlineDate(.init(title: "외출시간", date: alarm.deadlineDate)),
                                                                           .repeat(.init(title: "알람주기", value: AlarmCellModel(model: alarm).interval))] : []
                return [
                    AlarmDetailSectionModel(header: .none, items: [.wakeUpDate(.init(title: "기상시간", date: alarm.wakeUpDate)),
                                                                   .repeat(.init(title: "반복", value: AlarmCellModel(model: alarm).repeatDays)),
                                                                   .comment(.init(title: "메세지", value: alarm.comment))]),
                    AlarmDetailSectionModel(header: .repeat, items: deadlineSectionItems)
                ]
            }
            .bind(to: _sectionModels)
            .disposed(by: bag)
    }

    deinit {
        print("\(String(describing: self)) deinit")
    }
    
    func toggleDeadline(enable: Bool) {
        _toggleDeadline.accept(enable)
    }
    
    var toggleDeadline: Bool {
        return _toggleDeadline.value
    }
}
