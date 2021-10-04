//
//  Alarm.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import Foundation

struct Alarm: Codable, Equatable {
    let id: String
    var comment: String?
    var wakeUpDate: Date?
    var deadlineDate: Date?
    var notificationInterval: TimeInterval?
    var soundFileName: String?
    var repeatDays: [DayOfWeek]?
    var enable: Bool = false
    
    enum CodingKeys: CodingKey {
        case id
        case comment
        case wakeUpDate
        case deadlineDate
        case notificationInterval
        case soundFileName
        case repeatDays
    }
    
    init(comment: String?, wakeUpDate: Date?, deadlineDate: Date?, notificationInterval: TimeInterval?, soundFileName: String, repeatDays: [DayOfWeek]?, enable: Bool) {
        self.id = UUID().uuidString
        self.comment = comment
        self.wakeUpDate = wakeUpDate
        self.deadlineDate = deadlineDate
        self.notificationInterval = notificationInterval
        self.soundFileName = soundFileName
        self.repeatDays = repeatDays
        self.enable = enable
    }
}

enum DayOfWeek: Int, Codable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}
