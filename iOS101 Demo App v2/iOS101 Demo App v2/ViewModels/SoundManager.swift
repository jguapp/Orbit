import Foundation
import AVFoundation

class SoundManager: ObservableObject {
    @Published var isPlaying = false
    @Published var selectedSound: AmbientSound = .none
    private var audioPlayer: AVAudioPlayer?
    
    enum AmbientSound: String, CaseIterable {
        case none = "None"
        case rainforest = "Rainforest"
        case whiteNoise = "White Noise"
        case ocean = "Ocean Waves"
        case cafe = "Cafe Ambience"
        case lofi = "Lo-Fi"
        
        var fileName: String? {
            switch self {
            case .none: return nil
            case .rainforest: return "rainforest"
            case .whiteNoise: return "white-noise"
            case .ocean: return "ocean"
            case .cafe: return "cafe"
            case .lofi: return "lofi"
            }
        }
    }
    
    func playSound() {
        guard let soundName = selectedSound.fileName,
              let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            stopSound()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
}