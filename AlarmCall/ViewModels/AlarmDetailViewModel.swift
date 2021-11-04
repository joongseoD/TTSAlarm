//
//  AlarmDetailViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import RxSwift
import RxCocoa

protocol AlarmDetailViewModelDependency: AnyObject {
    var servicing: AlarmServicing { get }
    var alarmId: String? { get }
    var editCompletion: (() -> Void)? { get }
}

struct EditRepeatDaysComponent: EditAlarmRepeatDaysViewModelDependency {
    var dataSource: EditViewModelDataSource<DayOfWeek>
}

struct EditIntervalComponent: EditAlarmIntervalViewModelDependency {
    var dataSource: EditViewModelDataSource<Int>
}

struct EditCommentComponent: EditAlarmCommentViewModelDependency {
    var previousComment: String
    
    var editCompletion: ((String) -> Void)?
}

final class AlarmDetailViewModel: ViewModel {
    private let service: AlarmServicing
    private let _sectionModels = BehaviorRelay<[AlarmDetailSectionModel]>(value: [])
    private let _toggleDeadline = BehaviorRelay<Bool>(value: false)
    private let _moveToEdit = BehaviorRelay<Destination?>(value: nil)
    private let _completeSubmit = PublishSubject<Void>()
    private let defaultAlarm = Alarm(comment: "Alarm", wakeUpDate: Date(), deadlineDate: nil, notificationIntervalMinute: nil, repeatDays: nil, enable: false)
    
    private lazy var _currentAlarm: BehaviorRelay<Alarm> = {
        return BehaviorRelay<Alarm>(value: defaultAlarm)
    }()
    
    private var alarmId: String?
    private var alarmCompletion: (() -> Void)?
    private var bag = DisposeBag()
    private var dataConveyingBag = DisposeBag()
    private let dependency: AlarmDetailViewModelDependency
    
    init(dependency: AlarmDetailViewModelDependency) {
        self.dependency = dependency
        self.service = dependency.servicing
        self.alarmId = dependency.alarmId
        self.alarmCompletion = dependency.editCompletion
        
        setupCurrentAlarm(alarmId)
        setupSectionModels()
    }
    
    private func setupCurrentAlarm(_ alarmId: String?) {
        guard let alarmId = alarmId else { return }
        service.alarm(with: alarmId)
            .catch { [weak self] error in
                guard let self = self else { return .empty() }
                return .just(self.defaultAlarm)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] alarm in
                self?._currentAlarm.accept(alarm)
                self?._toggleDeadline.accept(alarm.deadlineDate != nil)
            })
            .disposed(by: bag)
    }
    
    private func setupSectionModels() {
        Observable.combineLatest(_currentAlarm, _toggleDeadline)
            .map { [weak self] alarm, toggle -> [AlarmDetailSectionModel] in
                guard let self = self else { return [] }
                self.dataConveyingBag = DisposeBag()
                
                let cellModel = AlarmCellModel(model: alarm)
                
                var deadlineSectionItems: [AlarmDetailSection] = []
                if toggle {
                    deadlineSectionItems =  [.deadlineDate(self.deadlineDateViewModel(alarm.deadlineDate)),
                                             .interval(.init(title: "알람주기", value: cellModel.interval))]
                }
                
                return [
                    AlarmDetailSectionModel(header: .none, items: [
                        .wakeUpDate(self.wakeUpDateViewModel(alarm.wakeUpDate)),
                        .repeat(.init(title: "반복", value: cellModel.repeatDays)),
                        .comment(.init(title: "메세지", value: cellModel.comment))
                    ]),
                    AlarmDetailSectionModel(header: .repeat, items: deadlineSectionItems)
                ]
            }
            .bind(to: _sectionModels)
            .disposed(by: bag)
    }

    private lazy var wakeUpDateViewModel: ((_ date: Date) -> AlarmDetailDateSectionViewModel) = {
        return { [weak self] date in
            guard let self = self else { return AlarmDetailDateSectionViewModel(title: "") }
            
            let dateViewModel = AlarmDetailDateSectionViewModel(title: "기상시간", date: date)
            dateViewModel.changedDate
                .withLatestFrom(self._currentAlarm) { (changedDate: $0, alarm: $1) }
                .subscribe(onNext: { [weak self] date, alarm in
                    var newAlarm = alarm
                    newAlarm.wakeUpDate = date
                    self?._currentAlarm.accept(newAlarm)
                })
                .disposed(by: self.dataConveyingBag)
            
            return dateViewModel
        }
    }()
    
    private lazy var deadlineDateViewModel: ((_ date: Date?) -> AlarmDetailDateSectionViewModel) = {
        return { [weak self] date in
            guard let self = self else { return AlarmDetailDateSectionViewModel(title: "") }
            
            let dateViewModel = AlarmDetailDateSectionViewModel(title: "외출시간", date: date)
            dateViewModel.changedDate
                .withLatestFrom(self._currentAlarm) { (changedDate: $0, alarm: $1) }
                .subscribe(onNext: { [weak self] date, alarm in
                    var newAlarm = alarm
                    newAlarm.deadlineDate = date
                    self?._currentAlarm.accept(newAlarm)
                })
                .disposed(by: self.dataConveyingBag)
            
            return dateViewModel
        }
    }()
    
    private lazy var changedComment: ((String) -> Void)? = {
        return { [weak self] comment in
            guard let self = self else { return }
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
                        return .editInterval(component: EditIntervalComponent(dataSource: viewModel.editIntervalDataSource))
                    case .repeat:
                        return .editRepeatDays(component: EditRepeatDaysComponent(dataSource: viewModel.editRepeatDaysDataSource))
                    case .comment:
                        return .editComment(component: EditCommentComponent(previousComment: viewModel._currentAlarm.value.comment, editCompletion: viewModel.changedComment))
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
                .compactMap { [weak self] _ in self?._currentAlarm.value }
                .flatMap(viewModel.service.saveAudioFile(alarm:))
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        viewModel._completeSubmit.onNext(())
                    case .failure(let error):
                        //TODO: - messaging
                        print("file save error: ", error.localizedDescription)
                    }
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
                if let newAlarm = self?._currentAlarm.value {
                    AlarmReservationCenter.shared.reserve(newAlarm)
                }

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
}
