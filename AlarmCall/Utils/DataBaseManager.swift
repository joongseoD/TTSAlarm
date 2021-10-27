//
//  Database.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import Foundation

protocol DataBaseManaging: AnyObject {
    init(key: DataBaseKeys)
    
    func append(newData: Data, id: String)
    
    func allData() -> [String:Data]?
    
    func select(with id: String) -> Data?
    
    func update(_ data: Data, id: String) -> Bool
    
    func delete(with id: String) -> Data?
}

extension DataBaseManaging {
    func select(with id: String) -> Data? {
        guard let datas = allData() else { return nil }
        return datas[id]
    }
}

enum DataBaseKeys: String {
    case AlarmList
}

final class DataBaseManager: DataBaseManaging {
    typealias Key = String
    typealias Value = Data
    
    private let key: Key
    
    init(key: DataBaseKeys) {
        self.key = key.rawValue
    }
    
    func append(newData: Value, id: Key) {
        if var datas = allData() {
            datas[id] = newData
            UserDefaults.standard.set(datas, forKey: key)
        } else {
            UserDefaults.standard.set([id:newData], forKey: key)
        }
    }
    
    func allData() -> [Key:Value]? {
        return UserDefaults.standard.dictionary(forKey: key) as? [Key:Value]
    }
    
    @discardableResult
    func update(_ data: Value, id: Key) -> Bool {
        guard var datas = allData() else { return false }
        
        let removedData = delete(with: id)
        datas[id] = data
        UserDefaults.standard.set(datas, forKey: key)
        
        return removedData != nil
    }
    
    func delete(with id: Key) -> Value? {
        guard var datas = allData() else { return nil }
        let removedValue = datas.removeValue(forKey: id)
        
        UserDefaults.standard.set(datas, forKey: key)
        
        return removedValue
    }
}

final class MockDataBaseManager: DataBaseManaging {
    typealias Key = String
    typealias Value = Data
    
    private let key: Key
    private var mockData: [Key:Value] = [:]
    init(key: DataBaseKeys) {
        self.key = key.rawValue
    }
    
    func append(newData: Value, id: Key) {
        if var datas = allData() {
            datas[id] = newData
            mockData = datas
        } else {
            mockData = [id:newData]
        }
    }
    
    func allData() -> [Key:Value]? {
        return mockData
    }
    
    @discardableResult
    func update(_ data: Value, id: Key) -> Bool {
        guard var datas = allData() else { return false }
        
        let removedData = delete(with: id)
        datas[id] = data
        mockData = datas
        
        return removedData != nil
    }
    
    func delete(with id: Key) -> Value? {
        guard var datas = allData() else { return nil }
        let removedValue = datas.removeValue(forKey: id)
        mockData = datas
        
        return removedValue
    }
}
