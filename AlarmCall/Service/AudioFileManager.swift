//
//  AudioFileManager.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/27.
//

import AVFoundation
import Foundation

enum FileError: Error, CustomStringConvertible {
    case filePath
    case unknownBufferType(buffer: AVAudioBuffer)
    case writeError
    
    var description: String {
        switch self {
        case .filePath: return "파일 경로가 잘못되었습니다."
        case let .unknownBufferType(buffer): return "버퍼 타입의 문제가 있습니다: \(buffer)"
        case .writeError: return "파일 저장 중 문제가 생겼습니다."
        }
    }
}

final class AudioFileManager {
    
    static let shared: AudioFileManager = {
        return AudioFileManager()
    }()
    
    private let filePath: URL? = {
        var url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        url?.appendPathComponent("Sounds", isDirectory: true)
        return url
    }()
    private let ext = ".caf"
    private let queue = DispatchQueue.global()
    
    private init() { createSoundsDirectory() }
    
    private func createSoundsDirectory() {
        guard let filePath = filePath else { return }
        do {
            try FileManager.default.createDirectory(atPath: filePath.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func saveFile(fileName: String, utterance: AVSpeechUtterance, completion: @escaping ((_ result: Result<Void, FileError>) -> Void)) {
        let synthesizer = AVSpeechSynthesizer()
        var output: AVAudioFile?
        
        synthesizer.write(utterance) { [unowned self] (buffer: AVAudioBuffer) in
            guard var filePath = self.filePath else {
                completion(.failure(.filePath))
                return
            }
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                completion(.failure(.unknownBufferType(buffer: buffer)))
                return
            }
            if pcmBuffer.frameLength == 0 {
                completion(.success(()))
            } else {
                do {
                    if output == nil {
                        filePath.appendPathComponent(fileName + self.ext)
                        output = try AVAudioFile(forWriting: filePath,
                                                 settings: pcmBuffer.format.settings,
                                                 commonFormat: .pcmFormatInt16,
                                                 interleaved: false)
                    }
                    try output?.write(from: pcmBuffer)
                    print("writting..")
                } catch {
                    completion(.failure(.writeError))
                }
            }
        }
    }
}
