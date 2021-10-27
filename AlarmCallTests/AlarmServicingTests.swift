//
//  AlarmServicingTests.swift
//  AlarmCallTests
//
//  Created by Damor on 2021/10/04.
//

import XCTest
import RxTest
import RxBlocking
import RxSwift
import RxCocoa

@testable import AlarmCall

class AlarmServicingTests: XCTestCase {
    
    let testScheduler = TestScheduler(initialClock: 0)
    var bag = DisposeBag()
    var service: AlarmServiging!
    var alarms: [Alarm]!
    
    override func setUpWithError() throws {
        service = MockAlarmService()
        alarms = (0...4).map { Alarm(comment: "\($0)", wakeUpDate: Date(), deadlineDate: nil, notificationIntervalMinute: nil, repeatDays: nil, enable: false) }
    }

    override func tearDownWithError() throws {
        service = nil
        alarms = []
    }
    
    func testAppendNewAlarm() {
        //given
        let alarms = alarms
        let result = testScheduler.createObserver(Int.self)
        
        //when
        testScheduler.start()
        service.append(alarms!)
            .flatMap { [unowned self] _ in
                self.service.alarmList()
                    .catch { error in
                        let serviceError = error as? AlarmServiceError
                        XCTFail(serviceError?.description ?? "")
                        return .just([])
                    }
            }
            .map { $0.count }
            .debug()
            .bind(to: result)
            .disposed(by: bag)
        
        //then
        let expected = Recorded.events(
            .next(0, alarms?.count ?? 0),
            .completed(0)
        )
        XCTAssertEqual(result.events, expected)
        testScheduler.stop()
    }
    
    func testFindAlarmAtEqualId() {
        //given
        let firstAlarm = alarms.first!
        service.append(alarms)
            .subscribe(onNext: {})
            .disposed(by: bag)
        
        
        //when
        testScheduler.start()
        let result = testScheduler.createObserver(Alarm.self)
        service.alarm(with: firstAlarm.id)
            .catch { error in
                let serviceError = error as? AlarmServiceError
                XCTFail(serviceError?.description ?? "")
                return .empty()
            }
            .debug()
            .bind(to: result)
            .disposed(by: bag)
        
        
        //then
        let expected = Recorded.events(
            .next(0, firstAlarm),
            .completed(0)
        )
        
        XCTAssertEqual(result.events, expected)
        testScheduler.stop()
    }
    
    func testUpdateAlarm() {
        
        //given
        var last = alarms.last!
        service.append(alarms)
            .subscribe(onNext: {})
            .disposed(by: bag)
        
        //when
        last.comment = "UPDATE"
        testScheduler.start()
        let result = testScheduler.createObserver(Alarm.self)
        Observable.just(last)
            .flatMap { [unowned self] alarm in
                self.service.update(alarm, id: alarm.id)
                    .catch { error in
                        let serviceError = error as? AlarmServiceError
                        XCTFail(serviceError?.description ?? "")
                        return .just(())
                    }
            }
            .flatMap { [unowned self] _ in
                self.service.alarm(with: last.id)
                    .catch { error in
                        let serviceError = error as? AlarmServiceError
                        XCTFail(serviceError?.description ?? "")
                        return .empty()
                    }
            }
            .bind(to: result)
            .disposed(by: bag)
        
        //then
        let expected = Recorded.events(
            .next(0, last),
            .completed(0)
        )
        
        XCTAssertEqual(result.events, expected)
        testScheduler.stop()
    }
    
    func testDeleteAlarm() {
        
        //given
        let last = alarms.last!
        service.append(alarms)
            .subscribe(onNext: {})
            .disposed(by: bag)
        
        //when
        testScheduler.start()
        let result = testScheduler.createObserver(Bool.self)
        Observable.just(last.id)
            .flatMap { [unowned self] id in
                self.service.delete(id: id)
                    .catch { error in
                        let serviceError = error as? AlarmServiceError
                        XCTFail(serviceError?.description ?? "")
                        return .just(())
                    }
            }
            .flatMap { [unowned self] in
                self.service.alarmList()
            }
            .map { $0.contains(last) }
            .bind(to: result)
            .disposed(by: bag)
        
        //then
        let expected = Recorded.events(
            .next(0, false),
            .completed(0)
        )
        
        XCTAssertEqual(result.events, expected)
        testScheduler.stop()
    }
}

final class MockAlarmService: AlarmServiging {
    private let dbms = MockDataBaseManager<String, Data>(key: .AlarmList)
    
    func append(_ items: [Alarm]) -> Observable<Void> {
        for item in items {
            guard let encodedData = try? Coder.encode(item) else { return .error(AlarmServiceError.encode) }
            dbms.append(newData: encodedData, id: item.id)
        }
        return .just(())
    }
    
    func append(_ alarm: Alarm) -> Observable<Void> {
        guard let encodedData = try? Coder.encode(alarm) else { return .error(AlarmServiceError.encode) }
        dbms.append(newData: encodedData, id: alarm.id)
        return .just(())
    }
    
    func alarmList() -> Observable<[Alarm]> {
        guard let datas = dbms.allData() else { return .just([]) }
        let models = datas.compactMap { data -> Alarm? in
            return try? Coder.model(encodedData: data.value)
        }
        return .just(models)
    }
    
    func alarm(with id: String) -> Observable<Alarm> {
        return alarmList()
            .compactMap {
                return $0.filter { $0.id == id }.first
            }
    }
    
    func update(_ alarm: Alarm, id: String) -> Observable<Void> {
        guard let data = try? Coder.encode(alarm) else { return .error(AlarmServiceError.encode) }
        if dbms.update(data, id: id) {
            return .just(())
        } else {
            return .error(AlarmServiceError.notFound)
        }
    }
    
    func delete(id: String) -> Observable<Void> {
        if dbms.delete(with: id) != nil {
            return .just(())
        } else {
            return .error(AlarmServiceError.notFound)
        }
    }
}

