//
//  TestToSpeachRecorder.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/06.
//

import AVFoundation

final class TestToSpeechRecorder: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var utterance: AVSpeechUtterance!
    //    private var voice: AVSpeechSynthesisVoice!
    
    override init() {
        super.init()
    }
    
    func speack(_ text: String) {
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        //TODO: 설정에서 조절 가능하도록 
        utterance.rate = 0.41
        utterance.pitchMultiplier = 0.7
        utterance.volume = 1
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth)
        synthesizer.speak(utterance)
    }
    
    func saveRecordFile() {
        guard let utterance = utterance else { return }
        var output: AVAudioFile?

        synthesizer.write(utterance) { (buffer: AVAudioBuffer) in
           guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
              fatalError("unknown buffer type: \(buffer)")
           }
           if pcmBuffer.frameLength == 0 {
             // done
           } else {
             // append buffer to file
               if output == nil {
                   output = try? AVAudioFile(forWriting: URL(fileURLWithPath: "test.caf"),
                                             settings: pcmBuffer.format.settings,
                                             commonFormat: .pcmFormatInt16,
                                             interleaved: false)
             }
             try? output?.write(from: pcmBuffer)
           }
        }
    }
}


