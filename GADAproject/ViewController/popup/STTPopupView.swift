//
//  STTPopupView.swift
//  handycab
//
//  Created by leejungchul on 2021/11/15.
//

import Foundation
import Speech
import UIKit

protocol SttDelegateProtocol: class {
    func deliverySttText(_ text: String)
}


class STTPopupView: UIViewController, SFSpeechRecognizerDelegate {

    public var confirmClick: (() -> ())?
    
    public var descString: String!
    public var confirmString: String!
    public var action: String!
    
    // MARK: STT - 변수처리
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var timer: Timer?
    weak var delegate: SttDelegateProtocol?
    private var isAudioRunning: Bool = false

    
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var speakBtn: UIButton!
    @IBOutlet weak var triangleView: TriangleView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var sttText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UsefulUtils.roundingCorner(view: btnView)
        UsefulUtils.roundingCorner(view: textView)
     
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func speakBtnClick(_ sender: UIButton) {
        print("speakBtnClick")
        if audioEngine.isRunning {
            // 오디오 인식이 실행중일때 클릭
            print("audioEngine.isRunning : \(audioEngine.isRunning)")
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)

            // 오디오 인식이 멈춘것으로 판별
            speakBtn.setImage(UIImage(named: "mic_wait"), for: .normal)
            textView.backgroundColor = .white
            sttText.text = "원하는 검색어를 말씀해주세요"
            sttText.textColor = .lightGray
            triangleView.isHidden = false
            
            pulseAnimationRemove()
        } else {
            // 오디오 인식이 실행중이지 않을때 클릭
            print("audioEngine.isRunning : \(audioEngine.isRunning)")
            startRecording()
            // 오디오 인식 중인 이미지 표출
            speakBtn.setImage(UIImage(named: "mic_play"), for: .normal)
            textView.backgroundColor = .clear
            sttText.text = "음성을 듣고 있습니다..."
            sttText.textColor = .white
            triangleView.isHidden = true
        }
    }
    func startRecording() {
        pulseAnimationPresent()
        print("startRecording")
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        print("audioSession")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        print("inputNode")
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        print("recognitionTask")
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            
            if result != nil {
                print("result?.bestTranscription.formattedString : \(result?.bestTranscription.formattedString)")
                print("result?.isFinal : \(result?.isFinal)")
                self.sttText.text = "\"\(result?.bestTranscription.formattedString ?? "")\""
                isFinal = (result?.isFinal)!
            }
            if isFinal {
                self.audioEngine.stop()
            } else if error == nil {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)

                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.speakBtn.isEnabled = true
                    self.speakBtn.setImage(UIImage(named: "mic_wait"), for: .normal)
                    
                    self.pulseAnimationRemove()
                    
                    self.delegate?.deliverySttText(result?.bestTranscription.formattedString ?? "")
                    
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
        
        print("recordingFormat")
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        print("prepare")
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error")
        }
    }
    
    func pulseAnimationPresent() {
        let pulse1 = PulseAnimation(numberOfPulse: Float.infinity, radius: 350, postion: self.view.center)
        pulse1.animationDuration = 1.0
        pulse1.backgroundColor = #colorLiteral(red: 0.5609684587, green: 0.5610520244, blue: 0.5609502196, alpha: 1)
        self.view.layer.insertSublayer(pulse1, below: self.btnView.layer)
        
        let pulse2 = PulseAnimation(numberOfPulse: Float.infinity, radius: 150, postion: self.view.center)
        pulse2.animationDuration = 1.0
        pulse2.backgroundColor = #colorLiteral(red: 0.5609684587, green: 0.5610520244, blue: 0.5609502196, alpha: 1)
        self.view.layer.insertSublayer(pulse2, below: self.btnView.layer)
        
        let pulse3 = PulseAnimation(numberOfPulse: Float.infinity, radius: 100, postion: self.view.center)
        pulse3.animationDuration = 1.0
        pulse3.backgroundColor = #colorLiteral(red: 0.5609684587, green: 0.5610520244, blue: 0.5609502196, alpha: 1)
        self.view.layer.insertSublayer(pulse3, below: self.btnView.layer)
        
        let pulse4 = PulseAnimation(numberOfPulse: Float.infinity, radius: 75, postion: self.view.center)
        pulse4.animationDuration = 1.0
        pulse4.backgroundColor = #colorLiteral(red: 0.5609807968, green: 0.5610482097, blue: 0.5609503388, alpha: 1)
        self.view.layer.insertSublayer(pulse4, below: self.btnView.layer)
    }
    
    func pulseAnimationRemove() {
        self.view.layer.sublayers?.remove(at: 0)
        self.view.layer.sublayers?.remove(at: 0)
        self.view.layer.sublayers?.remove(at: 0)
        self.view.layer.sublayers?.remove(at: 0)
    }
}
