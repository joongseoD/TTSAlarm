//
//  AlarmDetailSectionModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import RxDataSources

struct AlarmDetailSectionModel: SectionModelType {
    var header: AlarmDetailSectionHeader
    var items: [AlarmDetailSection]
    
    init(original: AlarmDetailSectionModel, items: [AlarmDetailSection]) {
        self = original
        self.items = items
    }
    
    init(header: AlarmDetailSectionHeader, items: [AlarmDetailSection]) {
        self.header = header
        self.items = items
    }
}

enum AlarmDetailSectionHeader {
    case none
    case `repeat`
}
