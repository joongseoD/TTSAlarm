//
//  EditViewModelDataSource.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import Foundation

struct EditViewModelDataSource<Element> {
    let values: [Element]
    let previousValues: [Element]?
    
    var changeValues: (([Element]) -> Void)?
}
