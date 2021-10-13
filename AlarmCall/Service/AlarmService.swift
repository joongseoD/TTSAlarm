//
//  AlarmService.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/04.
//

import RxSwift

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
    func append(_ items: [Alarm]) -> Observable<Void>
    
    func append(_ alarm: Alarm) -> Observable<Void>
    
    func alarmList() -> Observable<[Alarm]>
    
    func alarm(with id: String) -> Observable<Alarm>
    
    func update(_ alarm: Alarm, id: String) -> Observable<Void>
    
    func delete(id: String) -> Observable<Void>
}

final class AlarmService: AlarmServiging {
    
    private let dbms = DataBaseManager<String, Data>(key: .AlarmList)
    
    func append(_ items: [Alarm]) -> Observable<Void> {
        return Observable<Void>.create { [weak self] observer in
            for item in items {
                guard let encodedData = try? Coder.encode(item) else {
                    observer.onError(AlarmServiceError.encode)
                    return Disposables.create()
                }
                self?.dbms.append(newData: encodedData, id: item.id)
            }
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
            
        }
    }
    
    func append(_ alarm: Alarm) -> Observable<Void> {
        return Observable<Void>.create { [weak self] observer in
            guard let encodedData = try? Coder.encode(alarm) else {
                observer.onError(AlarmServiceError.encode)
                return Disposables.create()
            }
            self?.dbms.append(newData: encodedData, id: alarm.id)
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    
    func alarmList() -> Observable<[Alarm]> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let datas = self.dbms.allData() else {
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            
            let alarmList = datas.compactMap { data -> Alarm? in
                try? self.findAlarm(data.key)
            }
            .sorted(by: { $0.wakeUpDate < $1.wakeUpDate })
            observer.onNext(alarmList)
            observer.onCompleted()
            
            return Disposables.create()
        }
        
    }
    
    func alarm(with id: String) -> Observable<Alarm> {
        return Observable<Alarm>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            do {
                let model = try self.findAlarm(id)
                observer.onNext(model)
                observer.onCompleted()
            } catch {
                observer.onError(AlarmServiceError.notFound)
            }
            return Disposables.create()
        }
    }
    
    private func findAlarm(_ id: String) throws -> Alarm {
        guard let data = dbms.select(with: id) else { throw AlarmServiceError.notFound }
        return try Coder.model(encodedData: data)
    }
    
    func update(_ alarm: Alarm, id: String) -> Observable<Void> {
        return Observable<Void>.create { [weak self] observer in
            guard let self = self, let data = try? Coder.encode(alarm) else {
                observer.onError(AlarmServiceError.encode)
                return Disposables.create()
            }
            
            
            
            if self.dbms.update(data, id: id) {
                observer.onNext(())
                observer.onCompleted()
            } else {
                observer.onError(AlarmServiceError.notFound)
            }
            
            return Disposables.create()
        }
    }
    
    func delete(id: String) -> Observable<Void> {
        return Observable<Void>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            if self.dbms.delete(with: id) == nil {
                observer.onError(AlarmServiceError.notFound)
            } else {
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
        
    }
}
