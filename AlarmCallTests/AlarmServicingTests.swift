//
//  AlarmServicingTests.swift
//  AlarmCallTests
//
//  Created by Damor on 2021/10/04.
//

import XCTest
@testable import AlarmCall

class AlarmServicingTests: XCTestCase {
    var service: AlarmServiging!
    var alarms: [Alarm]!
    
    override func setUpWithError() throws {
        service = MockAlarmService()
        alarms = (0...4).map { Alarm(comment: "\($0)", wakeUpDate: nil, deadlineDate: nil, notificationInterval: nil, soundFileName: "\($0)", repeatDays: nil) }
    }

    override func tearDownWithError() throws {
        service = nil
        alarms = []
    }
    
    func testAppendNewAlarm() {
        //given
        let alarms = alarms
        do {
            //when
            try service.append(alarms!)
            
            //then
            XCTAssertEqual(service.count, alarms!.count)
        } catch {
            let serviceError = error as? AlarmServiceError
            XCTFail(serviceError?.description ?? "")
        }
    }
    
    func testFindAlarmAtEqualId() {
        do {
            //given
            let firstAlarm = alarms.first!
            try service.append(alarms)
        
            
            //when
            let foundAlarm = try service.alarm(with: firstAlarm.id)
            print("# found \(foundAlarm) firstAlarm \(firstAlarm)")
            
            //then
            XCTAssertEqual(foundAlarm, firstAlarm)

        } catch {
            let serviceError = error as? AlarmServiceError
            XCTFail(serviceError?.description ?? "")
        }
    }
    
    func testUpdateAlarm() {
        do {
            //given
            var last = alarms.last!
            try service.append(alarms)
            
            //when
            last.comment = "UPDATE"
            try service.update(last, id: last.id)
            
            //then
            let alarm = try service.alarm(with: last.id)
            XCTAssertEqual(alarm.comment, last.comment)
            
        } catch {
            let serviceError = error as? AlarmServiceError
            XCTFail(serviceError?.description ?? "")
        }
    }
    
    func testDeleteAlarm() {
        do {
            //given
            let last = alarms.last!
            try service.append(alarms)
            
            //when
            try service.delete(id: last.id)
            
            //then
            let alarmList = service.alarmList()
            XCTAssert(!alarmList.contains(last))
            XCTAssertThrowsError(try service.alarm(with: last.id))
            
        } catch {
            let serviceError = error as? AlarmServiceError
            XCTFail(serviceError?.description ?? "")
        }
    }
}

final class MockAlarmService: AlarmServiging {
    
    private let dbms = MockDataBaseManager<String, Data>(key: .AlarmList)
    
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

