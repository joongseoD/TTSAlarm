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
    private let _toggleDeadline = BehaviorRelay<Bool>(value: false)
    private let _moveToEdit = BehaviorRelay<Destination?>(value: nil)
    private let _completeSubmit = PublishSubject<Void>()
    private lazy var _currentAlarm: BehaviorRelay<Alarm> = { [unowned self] in
        return BehaviorRelay<Alarm>(value: self.defaultAlarm)
    }()
    
    private var alarmId: String?
    private var alarmCompletion: (() -> Void)?
    private var bag = DisposeBag()
    
    init(service: AlarmServiging = AlarmService(), alarmId: String?, completion: (() -> Void)?) {
        self.service = service
        self.alarmId = alarmId
        self.alarmCompletion = completion
        
        setUp()
        setUpCurrentAlarm(alarmId)
    }
    
    private func setUpCurrentAlarm(_ alarmId: String?) {
        guard let alarmId = alarmId else { return }
        service.alarm(with: alarmId)
            .catch { [weak self] error in
                guard let self = self else { return .empty() }
                return .just(self.defaultAlarm)
            }
            .subscribe(onNext: { [weak self] alarm in
                self?._currentAlarm.accept(alarm)
                self?._toggleDeadline.accept(alarm.deadlineDate != nil)
            })
            .disposed(by: bag)
    }
    
    private func setUp() {
        Observable.combineLatest(_currentAlarm, _toggleDeadline)
            .map { [weak self] alarm, toggle -> [AlarmDetailSectionModel] in
                guard let self = self else { return [] }
                
                var deadlineSectionItems: [AlarmDetailSection] = []
                if toggle {
                    deadlineSectionItems =  [.deadlineDate(self.deadlineDateViewModel(alarm.deadlineDate)),
                                             .interval(.init(title: "알람주기", value: AlarmCellModel(model: alarm).interval))]
                }
                
                return [
                    AlarmDetailSectionModel(header: .none, items: [.wakeUpDate(self.wakeUpDateViewModel(alarm.wakeUpDate)),
                                                                   .repeat(.init(title: "반복", value: AlarmCellModel(model: alarm).repeatDays)),
                                                                   .comment(.init(title: "메세지", value: alarm.comment))]),
                    AlarmDetailSectionModel(header: .repeat, items: deadlineSectionItems)
                ]
            }
            .bind(to: _sectionModels)
            .disposed(by: bag)
    }

    private lazy var wakeUpDateViewModel: ((_ date: Date) -> AlarmDetailDateSectionViewModel) = { [weak self] in
        return { date in
            guard let self = self else { return AlarmDetailDateSectionViewModel(title: "") }
            let dateViewModel = AlarmDetailDateSectionViewModel(title: "기상시간", date: date)
            dateViewModel.changedDate
                .withLatestFrom(self._currentAlarm) { (changedDate: $0, alarm: $1) }
                .subscribe(onNext: { date, alarm in
                    var newAlarm = alarm
                    newAlarm.wakeUpDate = date
                    self._currentAlarm.accept(newAlarm)
                })
                .disposed(by: self.bag)
            
            return dateViewModel
        }
    }()
    
    private lazy var deadlineDateViewModel: ((_ date: Date?) -> AlarmDetailDateSectionViewModel) = { [weak self] in
        return { date in
            guard let self = self else { return AlarmDetailDateSectionViewModel(title: "") }
            let dateViewModel = AlarmDetailDateSectionViewModel(title: "외출시간", date: date)
            dateViewModel.changedDate
                .withLatestFrom(self._currentAlarm) { (changedDate: $0, alarm: $1) }
                .subscribe(onNext: { date, alarm in
                    var newAlarm = alarm
                    newAlarm.deadlineDate = date
                    self._currentAlarm.accept(newAlarm)
                })
                .disposed(by: self.bag)
            
            return dateViewModel
        }
    }()
    
    private lazy var changedComment: ((String) -> Void)? = { [weak self] in
        guard let self = self else { return nil }
        return { comment in
            var alarm = self._currentAlarm.value
            alarm.comment = comment
            self._currentAlarm.accept(alarm)
        }
    }()
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}

//MARK: - Binder
extension AlarmDetailViewModel {
    var selectedIndex: Binder<IndexPath> {
        return Binder(self) { viewModel, indexPath in
            Observable.just(indexPath)
                .withLatestFrom(viewModel._sectionModels) { indexPath, sectionModels -> Destination? in
                    let section = sectionModels[indexPath.section]
                    let row = section.items[indexPath.row]
                    
                    switch row {
                    case .interval:
                        return .editInterval(dataSource: viewModel.editIntervalDataSource)
                    case .repeat:
                        return .editRepeatDays(dataSource: viewModel.editRepeatDaysDataSource)
                    case .comment:
                        return .editComment(previous: viewModel._currentAlarm.value.comment, completion: viewModel.changedComment)
                    default:
                        return nil
                    }
                }
                .bind(to: viewModel._moveToEdit)
                .disposed(by: viewModel.bag)
        }
    }
    
    var submitAlarm: Binder<Void> {
        return Binder(self) { viewModel, _ in
            viewModel.service.append(viewModel._currentAlarm.value)
                .catch { error in
                    print("## error", error.localizedDescription)
                    //TODO: 에러처리
                    return .empty()
                }
                .subscribe(onNext: {
                    viewModel._completeSubmit.onNext(())
                })
                .disposed(by: viewModel.bag)
        }
    }
}

//MARK: - Input Interface
extension AlarmDetailViewModel {
    func toggleDeadline(enable: Bool) {
        _toggleDeadline.accept(enable)
    }
}

//MARK: - Output Interface
extension AlarmDetailViewModel {
    var isEditMode: Bool {
        return alarmId != nil
    }
    
    var toggleDeadline: Bool {
        return _toggleDeadline.value
    }
    
    var completeSubmit: Observable<Void> {
        return _completeSubmit
            .do(onNext: { [weak self] in
                self?.alarmCompletion?()
            })
            .asObservable()
    }
    
    var moveToEdit: Driver<Destination> {
        return _moveToEdit.asDriver().compactMap { $0 }
    }

    var currentAlarm: Driver<Alarm> {
        return _currentAlarm.asDriver(onErrorJustReturn: defaultAlarm)
    }
        
    var sectionModels: Driver<[AlarmDetailSectionModel]> {
        return _sectionModels.asDriver()
    }
}

//MARK: - Private Computed Properties
extension AlarmDetailViewModel {
    private var editIntervalDataSource: EditViewModelDataSource<Int> {
        var intervals: [Int] = []
        if let interval = _currentAlarm.value.notificationIntervalMinute {
            intervals = [interval]
        }
        
        let dataSource = EditViewModelDataSource(values: NotificationInterval.allCases.map { $0.rawValue }, previousValues: intervals) { [weak self] interval in
            guard let self = self else { return }
            var alarm = self._currentAlarm.value
            alarm.notificationIntervalMinute = interval.first
            self._currentAlarm.accept(alarm)
        }
        return dataSource
    }
    
    private var editRepeatDaysDataSource: EditViewModelDataSource<DayOfWeek> {
        let repeatDays = _currentAlarm.value.repeatDays ?? []
        
        let dataSource = EditViewModelDataSource(values: DayOfWeek.allCases, previousValues: repeatDays) { [weak self] days in
            guard let self = self else { return }
            var alarm = self._currentAlarm.value
            alarm.repeatDays = days
            self._currentAlarm.accept(alarm)
        }
        return dataSource
    }
    
    private var editCommentDataSource: EditViewModelDataSource<String> {
        let currentComment = _currentAlarm.value.comment
        let dataSource = EditViewModelDataSource(values: [], previousValues: [currentComment]) { [weak self] comment in
            guard let self = self else { return }
            var alarm = self._currentAlarm.value
            alarm.comment = comment.first ?? currentComment
            self._currentAlarm.accept(alarm)
        }
        return dataSource
    }
    
    private var defaultAlarm: Alarm {
        Alarm(comment: "Alarm", wakeUpDate: Date(), deadlineDate: nil, notificationIntervalMinute: nil, soundFileName: nil, repeatDays: nil, enable: false)
    }
}
