//
//  AlarmDetailViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import Foundation

final class AlarmDetailViewModel: ViewModelType {
    
    private let service: AlarmServiging
    
    init(service: AlarmServiging = AlarmService(), alarmId: String?) {
        self.service = service
//        print("test ", alarmId)
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}
