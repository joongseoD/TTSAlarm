//
//  TestToSpeachRecorder.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/06.
//

import AVFoundation

final class TTSRecorder: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private(set) var utterance: AVSpeechUtterance
    
    init(text: String) {
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.41
        utterance.pitchMultiplier = 0.8
        utterance.volume = 1
    }
    
    func speack() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth)
        synthesizer.speak(utterance)
    }
    
    var rate: Float {
        get {
            utterance.rate
        }
        set {
            utterance.rate = newValue
        }
    }
    
    var pitchMultiplier: Float {
        get {
            utterance.pitchMultiplier
        }
        set {
            utterance.pitchMultiplier = newValue
        }
    }
    
    var volume: Float {
        get {
            utterance.volume
        }
        set {
            utterance.volume = newValue
        }
    }
}
