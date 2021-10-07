//
//  AlarmCellModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import UIKit
import RxDataSources

struct AlarmSectionModel: SectionModelType {
    typealias Item = AlarmCellModel
    
    var items: [Item]
    
    init(items: [AlarmCellModel]) {
        self.items = items
    }
    
    init(original: AlarmSectionModel, items: [AlarmCellModel]) {
        self = original
        self.items = items
    }
}

struct AlarmCellModel {
    var id: String
    var time: String
    var midday: String
    var isOn: Bool
    var comment: String
    var repeatDays: String
    var interval: String?
    var deadlineTime: String?
    var description: String {
        return comment + repeatDays
    }
    
    init(model: Alarm) {
        self.id = model.id
        let wakeUpDate = model.wakeUpDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.time = dateFormatter.string(from: wakeUpDate)
        
        let amFormatter = DateFormatter()
        amFormatter.dateFormat = "a"
        self.midday = amFormatter.string(from: wakeUpDate)
        
        self.comment = model.comment
        self.repeatDays = model.repeatDays?
            .map { $0.rawValue }
            .reduce("", { $0 + " " + $1 }) ?? ""
        self.isOn = model.enable
        
        if let deadlineDate = model.deadlineDate {
            self.deadlineTime = dateFormatter.string(from: deadlineDate)
        }
        
        if let interval = model.notificationIntervalMinute {
            self.interval = "\(interval)분 마다"
        }
    }
}
