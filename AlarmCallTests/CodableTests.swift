//
//  CodableTests.swift
//  AlarmCallTests
//
//  Created by Damor on 2021/10/04.
//

import XCTest
@testable import AlarmCall

class CodableTests: XCTestCase {
    var model: Alarm!
    var copiedModel: Alarm!
    
    override func setUpWithError() throws {
        model = Alarm(comment: "test",
              wakeUpDate: Date(),
              deadlineDate: Date(),
              notificationIntervalMinute: 1,
              soundFileName: "sound",
              repeatDays: [.Mon],
              enable: false)
        
        copiedModel = model
    }

    override func tearDownWithError() throws {
        model = nil
        copiedModel = nil
    }

    func testEqualEncodedDataWithModelAndCopiedModel() {
        //when
        let data = try? Coder.encode(model)
        let secondData = try? Coder.encode(copiedModel)
        
        //then
        XCTAssertEqual(data, secondData)
    }
    
    func testEqualDecodedModelWithCopiedModel() {
        //given
        guard let data = try? Coder.encode(model),
              let secondData = try? Coder.encode(copiedModel) else {
            XCTFail("EncodingError")
            return
        }
        
        //when
        let model: Alarm? = try? Coder.model(encodedData: data)
        let secondModel: Alarm? = try? Coder.model(encodedData: secondData)
        
        //then
        XCTAssertEqual(model, secondModel)
    }
    
    func testNotEqualModelAndNewModel() {
        //given
        var newModel = model
        
        //when
        newModel?.comment = "new model test"
        
        let data = try? Coder.encode(model)
        let newModelData = try? Coder.encode(newModel)
        
        //then
        XCTAssertNotEqual(data, newModelData)
    }
    
    
}

