//
//  Alarm.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import Foundation

struct Alarm: Codable, Equatable {
    let id: String
    var comment: String
    var wakeUpDate: Date
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
        case enable
    }
    
    init(comment: String, wakeUpDate: Date, deadlineDate: Date?, notificationInterval: TimeInterval?, soundFileName: String, repeatDays: [DayOfWeek]?, enable: Bool) {
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

enum DayOfWeek: String, Codable {
    case Sun
    case Mon
    case Tue
    case Wed
    case Thu
    case Fri
    case Sat
}
