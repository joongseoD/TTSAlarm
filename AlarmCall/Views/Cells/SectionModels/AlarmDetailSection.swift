//
//  AlarmDetailSection.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import UIKit

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
