//
//  AlarmDetailDateSectionViewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import RxSwift

struct AlarmDetailDateSectionViewModel: AlarmDetailSectionViewModelType, ConvenyingChangedDate {
    var title: String
    var date: Date?
    
    var changedDate = PublishSubject<Date>()
}
