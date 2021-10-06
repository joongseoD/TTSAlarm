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
    var description: String
    var midday: String
    var isOn: Bool
    
    init(model: Alarm) {
        self.id = model.id
        let wakeUpDate = model.wakeUpDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.time = dateFormatter.string(from: wakeUpDate)
        
        let amFormatter = DateFormatter()
        amFormatter.dateFormat = "a"
        self.midday = amFormatter.string(from: wakeUpDate)
        
        let comment = model.comment
        let repeatDays = model.repeatDays?
            .map { $0.rawValue }
            .reduce("", { $0 + " " + $1 }) ?? ""
        
        self.description = comment + repeatDays
        self.isOn = model.enable
    }
}
