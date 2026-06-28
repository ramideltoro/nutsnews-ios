//
//  NutsNewsListenController.swift
//  NutsNews
//

import AVFoundation
import Combine
import Foundation

final class NutsNewsListenController: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    enum PlaybackState {
        case idle
        case reading
        case paused

        var isActive: Bool {
            switch self {
            case .idle:
                return false
            case .reading, .paused:
                return true
            }
        }
    }

    @Published private(set) var playbackState: PlaybackState = .idle
    @Published private(set) var statusMessage = "Ready to listen"

    private let synthesizer = AVSpeechSynthesizer()
    private var queuedUtteranceCount = 0
    private var finishedUtteranceCount = 0
    private var selectedVoiceName = "iOS voice"

    var isActive: Bool {
        playbackState.isActive
    }

    var iconName: String {
        switch playbackState {
        case .idle:
            return "waveform.circle.fill"
        case .reading:
            return "speaker.wave.2.circle.fill"
        case .paused:
            return "pause.circle.fill"
        }
    }

    var primaryButtonTitle: String {
        switch playbackState {
        case .idle:
            return "Listen to brief"
        case .reading:
            return "Pause"
        case .paused:
            return "Resume"
        }
    }

    var primaryButtonIconName: String {
        switch playbackState {
        case .idle:
            return "play.fill"
        case .reading:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }

    var shortStatusMessage: String {
        switch playbackState {
        case .idle:
            return "Ready"
        case .reading:
            return "Reading"
        case .paused:
            return "Paused"
        }
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func toggle(script: String) {
        switch playbackState {
        case .idle:
            speak(script: script)
        case .reading:
            pause()
        case .paused:
            resume()
        }
    }

    func stop() {
        guard playbackState.isActive || synthesizer.isSpeaking || synthesizer.isPaused else {
            return
        }

        queuedUtteranceCount = 0
        finishedUtteranceCount = 0
        synthesizer.stopSpeaking(at: .immediate)
        playbackState = .idle
        statusMessage = "Stopped"
    }

    private func speak(script: String) {
        let segments = naturalSpeechSegments(from: script)

        guard !segments.isEmpty else {
            statusMessage = "Nothing to read yet"
            playbackState = .idle
            return
        }

        configureAudioSessionForSpokenBrief()

        let voice = preferredNaturalVoice()
        selectedVoiceName = voice?.name ?? "iOS voice"
        queuedUtteranceCount = segments.count
        finishedUtteranceCount = 0

        playbackState = .reading
        statusMessage = "Reading with \(selectedVoiceName)"

        for (index, segment) in segments.enumerated() {
            let utterance = AVSpeechUtterance(string: spokenFriendlyText(segment))
            utterance.voice = voice
            utterance.rate = naturalSpeechRate(for: segment)
            utterance.pitchMultiplier = naturalPitchMultiplier(for: voice)
            utterance.volume = 1.0
            utterance.preUtteranceDelay = index == 0 ? 0.0 : pauseBeforeSegment(segment)
            utterance.postUtteranceDelay = pauseAfterSegment(segment)
            synthesizer.speak(utterance)
        }
    }

    private func pause() {
        guard synthesizer.isSpeaking else {
            playbackState = .idle
            statusMessage = "Ready to listen"
            return
        }

        synthesizer.pauseSpeaking(at: .word)
        playbackState = .paused
        statusMessage = "Paused"
    }

    private func resume() {
        guard synthesizer.isPaused else {
            playbackState = .idle
            statusMessage = "Ready to listen"
            return
        }

        synthesizer.continueSpeaking()
        playbackState = .reading
        statusMessage = "Reading with \(selectedVoiceName)"
    }

    private func naturalSpeechSegments(from script: String) -> [String] {
        script
            .components(separatedBy: .newlines)
            .map { line in
                line
                    .replacingOccurrences(of: "  ", with: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
    }

    private func spokenFriendlyText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "NutsNews", with: "Nuts News")
            .replacingOccurrences(of: "AI", with: "A I")
            .replacingOccurrences(of: "iOS", with: "I O S")
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: " — ", with: ", ")
            .replacingOccurrences(of: " – ", with: ", ")
    }

    private func preferredNaturalVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { voice in
                voice.language == "en-US" || voice.language.hasPrefix("en-")
            }

        guard !voices.isEmpty else {
            return AVSpeechSynthesisVoice(language: "en-US")
        }

        let preferredNames = [
            "Samantha", "Ava", "Allison", "Susan", "Zoe", "Noelle", "Evan", "Tom", "Daniel", "Serena", "Moira", "Karen"
        ]

        let sortedVoices = voices.sorted { lhs, rhs in
            let lhsScore = voiceScore(lhs, preferredNames: preferredNames)
            let rhsScore = voiceScore(rhs, preferredNames: preferredNames)

            if lhsScore != rhsScore {
                return lhsScore > rhsScore
            }

            if lhs.language != rhs.language {
                return lhs.language == "en-US"
            }

            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        return sortedVoices.first ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    private func voiceScore(_ voice: AVSpeechSynthesisVoice, preferredNames: [String]) -> Int {
        var score = 0

        if voice.language == "en-US" {
            score += 100
        } else if voice.language.hasPrefix("en-") {
            score += 45
        }

        score += qualityScore(for: voice) * 30

        if let preferredIndex = preferredNames.firstIndex(where: { voice.name.localizedCaseInsensitiveContains($0) }) {
            score += max(0, 30 - preferredIndex)
        }

        if voice.name.localizedCaseInsensitiveContains("Siri") {
            score += 8
        }

        return score
    }

    private func qualityScore(for voice: AVSpeechSynthesisVoice) -> Int {
        switch voice.quality {
        case .premium:
            return 3
        case .enhanced:
            return 2
        case .default:
            return 1
        @unknown default:
            return 1
        }
    }

    private func naturalSpeechRate(for segment: String) -> Float {
        let baseRate = AVSpeechUtteranceDefaultSpeechRate

        if segment.count < 42 {
            return baseRate * 0.79
        }

        if segment.localizedCaseInsensitiveContains("takeaway") {
            return baseRate * 0.80
        }

        return baseRate * 0.84
    }

    private func naturalPitchMultiplier(for voice: AVSpeechSynthesisVoice?) -> Float {
        guard let voice else {
            return 0.94
        }

        if voice.name.localizedCaseInsensitiveContains("Siri") {
            return 0.98
        }

        return 0.94
    }

    private func pauseBeforeSegment(_ segment: String) -> TimeInterval {
        if segment.localizedCaseInsensitiveContains("what happened") ||
            segment.localizedCaseInsensitiveContains("why it") ||
            segment.localizedCaseInsensitiveContains("takeaway") ||
            segment.localizedCaseInsensitiveContains("source") {
            return 0.34
        }

        return 0.20
    }

    private func pauseAfterSegment(_ segment: String) -> TimeInterval {
        if segment.localizedCaseInsensitiveContains("takeaway") {
            return 0.42
        }

        if segment.count < 42 {
            return 0.30
        }

        return 0.22
    }

    private func configureAudioSessionForSpokenBrief() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true, options: [])
        } catch {
            // Speech still works in most simulator/device cases even if the audio session cannot be configured.
        }
        #endif
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.finishedUtteranceCount += 1

            if self.finishedUtteranceCount >= self.queuedUtteranceCount {
                self.queuedUtteranceCount = 0
                self.finishedUtteranceCount = 0
                self.playbackState = .idle
                self.statusMessage = "Finished reading"
            }
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.queuedUtteranceCount = 0
            self?.finishedUtteranceCount = 0
            self?.playbackState = .idle
        }
    }
}
