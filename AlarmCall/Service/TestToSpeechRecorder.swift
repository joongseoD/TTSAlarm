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


