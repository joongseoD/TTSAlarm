//
//  Database.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import Foundation

protocol DataBaseManaging {
    associatedtype Key: Hashable
    associatedtype Value
    
    init(key: DataBaseKeys)
    
    func append(newData: Value, id: Key)
    
    func allData() -> [Key:Value]?
    
    func select(with id: Key) -> Value?
    
    func update(_ data: Value, id: Key) -> Bool
    
    func delete(with id: Key) -> Value?
}

extension DataBaseManaging {
    func select(with id: Key) -> Value? {
        guard let datas = allData() else { return nil }
        return datas[id]
    }
}

enum DataBaseKeys: String {
    case AlarmList
}

final class DataBaseManager<Key: Hashable, Value>: DataBaseManaging {
    typealias Key = Key
    typealias Value = Value
    
    private let key: String
    
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

final class MockDataBaseManager<Key: Hashable, Value>: DataBaseManaging {
    typealias Key = Key
    typealias Value = Value
    
    private let key: String
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
