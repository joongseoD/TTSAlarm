//
//  ConvenyingChangedDate.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import RxSwift

protocol ConvenyingChangedDate {
    var changedDate: PublishSubject<Date> { get set }
}
