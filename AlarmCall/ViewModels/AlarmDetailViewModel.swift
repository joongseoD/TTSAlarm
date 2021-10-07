//
//  AlarmDetailViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import RxSwift
import RxCocoa
import RxDataSources

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

struct AlarmDetailSectionModel: SectionModelType {
    var header: AlarmDetailSectionHeader
    var items: [AlarmDetailSection]
    
    init(original: AlarmDetailSectionModel, items: [AlarmDetailSection]) {
        self = original
        self.items = items
    }
    
    init(header: AlarmDetailSectionHeader, items: [AlarmDetailSection]) {
        self.header = header
        self.items = items
    }
}

enum AlarmDetailSectionHeader {
    case none
    case `repeat`
}

protocol AlarmDetailSectionViewModelType {
    var title: String { get set }
}

struct AlarmDetailDateSectionViewModel: AlarmDetailSectionViewModelType {
    var title: String
    var date: Date?
}

struct AlarmDetailSelectSectionViewModel: AlarmDetailSectionViewModelType {
    var title: String
    var value: String?
}

enum AlarmDetailSection: CaseIterable {
    case wakeUpDate(_: AlarmDetailDateSectionViewModel)
    case `repeat`(_: AlarmDetailSelectSectionViewModel)
    case comment(_: AlarmDetailSelectSectionViewModel)
    case deadlineDate(_: AlarmDetailDateSectionViewModel)
    case interval(_: AlarmDetailSelectSectionViewModel)
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .wakeUpDate, .deadlineDate: return AlarmDetailDatePickerTableViewCell.self
        case .comment, .interval, .repeat: return AlarmDetailSelectTableViewCell.self
        }
    }
    
    var reuseIdentifier: String {
        switch self {
        case .wakeUpDate: return "wakeUpDate"
        case .repeat: return "repeat"
        case .comment: return "comment"
        case .deadlineDate: return "deadlineDate"
        case .interval: return "interval"
        }
    }
    
    var headerType: AlarmDetailSectionHeader {
        switch self {
        case .wakeUpDate, .comment, .repeat: return .none
        case .deadlineDate, .interval: return .repeat
        }
    }
    
    var viewModel: AlarmDetailSectionViewModelType {
        switch self {
        case let .wakeUpDate(viewModel): return viewModel
        case let .repeat(viewModel): return viewModel
        case let .comment(viewModel): return viewModel
        case let .deadlineDate(viewModel): return viewModel
        case let .interval(viewModel): return viewModel
        }
    }
    
    static var allCases: [AlarmDetailSection] {
        return [
            .wakeUpDate(AlarmDetailDateSectionViewModel(title: "기상 시간")),
            .repeat(AlarmDetailSelectSectionViewModel(title: "반복")),
            .comment(AlarmDetailSelectSectionViewModel(title: "문구")),
            .deadlineDate(AlarmDetailDateSectionViewModel(title: "외출 시간")),
            .interval(AlarmDetailSelectSectionViewModel(title: "알림 주기"))
        ]
    }
    
    var title: String {
        switch self {
        case .repeat: return "반복"
        case .comment: return "문구"
        case .interval: return "알림 주기"
        case .wakeUpDate: return "기상 시간"
        case .deadlineDate: return "외출 시간"
        }
    }
}
