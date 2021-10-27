//
//  AlarmReservationCenter.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/06.
//

import Foundation
import UserNotifications

final class AlarmReservationCenter {
    static let shared = AlarmReservationCenter()
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { result, error in
            guard error == nil else {
                fatalError("auth error")
            }
            completion(result)
        }
    }
    
    func reserve(_ alarm: Alarm, completion: ((Bool) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = alarm.comment
        content.body = alarm.comment
        content.sound = UNNotificationSound(named: .init(alarm.soundFileName))
        
        let componentSet = Set(arrayLiteral: Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.weekday)
        
        
        //TODO: - 매주 요일마다 반복 & 나갈 시간 까지 반복 추가
//        alarm.repeatDays
        
        let dateComponents = Calendar.current.dateComponents(componentSet, from: alarm.wakeUpDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: alarm.id,
                                            content: content,
                                            trigger: trigger)
        
        self.center.add(request) { error in
            if let error = error {
                fatalError("alarm reserve error: \(error.localizedDescription)")
            }
            completion?(true)
            print("## reserved")
        }
    }
}
