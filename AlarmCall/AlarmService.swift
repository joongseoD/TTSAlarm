//
//  AlarmService.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import Foundation

enum AlarmServiceError: Error, CustomStringConvertible {
    case encode
    case decode
    case notFound
    
    var description: String {
        switch self {
        case .encode: return "encoding error"
        case .decode: return "decoding error"
        case .notFound: return "not found id"
        }
    }
}

protocol AlarmServiging {
    func append(_ items: [Alarm]) throws
    
    func append(_ alarm: Alarm) throws
    
    func alarmList() -> [Alarm]
    
    func alarm(with id: String) throws -> Alarm
    
    @discardableResult
    func update(_ alarm: Alarm, id: String) throws -> Bool
    
    func delete(id: String) throws
}

extension AlarmServiging {
    var count: Int {
        return alarmList().count
    }
    
    var isEmpty: Bool {
        return count == 0
    }
}

final class AlarmService: AlarmServiging {
    
    private let dbms = DataBaseManager<String, Data>(key: .AlarmList)
    
    func append(_ items: [Alarm]) throws {
        for item in items {
            try append(item)
        }
    }
    
    func append(_ alarm: Alarm) throws {
        guard let encodedData = try? Coder.encode(alarm) else { throw AlarmServiceError.encode }
        dbms.append(newData: encodedData, id: alarm.id)
    }
    
    func alarmList() -> [Alarm] {
        guard let datas = dbms.allData() else { return [] }
        
        return datas.compactMap { data -> Alarm? in
            try? alarm(with: data.key)
        }
    }
    
    func alarm(with id: String) throws -> Alarm {
        guard let data = dbms.select(with: id) else { throw AlarmServiceError.notFound }
        return try Coder.model(encodedData: data)
    }
    
    @discardableResult
    func update(_ alarm: Alarm, id: String) throws -> Bool {
        guard let data = try? Coder.encode(alarm) else { throw AlarmServiceError.encode }
        return dbms.update(data, id: id)
    }
    
    func delete(id: String) throws {
        if dbms.delete(with: id) == nil {
            throw AlarmServiceError.notFound
        }
    }
}
