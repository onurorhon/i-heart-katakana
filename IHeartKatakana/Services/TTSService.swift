import AVFoundation

@MainActor
@Observable
class TTSService {
    private let synthesizer = AVSpeechSynthesizer()
    private(set) var isSpeaking = false
    private var isAudioSessionConfigured = false

    private static let hasShownVoiceHintKey = "hasShownVoiceHint"

    var shouldShowVoiceHint: Bool {
        !UserDefaults.standard.bool(forKey: Self.hasShownVoiceHintKey)
    }

    func markVoiceHintShown() {
        UserDefaults.standard.set(true, forKey: Self.hasShownVoiceHintKey)
    }

    func speak(_ text: String) {
        // Configure audio session if needed
        if !isAudioSessionConfigured {
            configureAudioSession()
        }

        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = preferredJapaneseVoice()
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        synthesizer.speak(utterance)
    }

    private func preferredJapaneseVoice() -> AVSpeechSynthesisVoice? {
        let japaneseVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("ja") }

        // Sort by quality (premium = 3, enhanced = 2, default = 1)
        let sorted = japaneseVoices.sorted { $0.quality.rawValue > $1.quality.rawValue }

        return sorted.first ?? AVSpeechSynthesisVoice(language: "ja-JP")
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            isAudioSessionConfigured = true
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}
