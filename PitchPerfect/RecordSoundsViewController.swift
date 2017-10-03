//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Marvin Mante on 9/14/17.
//  Copyright © 2017 MarvyMarv. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Alerts
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Attempt to record audio was not successful."
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: Label and Buttons
    
    // declare our UILabel and UIButton elements
    // - this can be done by creating the element buttons via storyboard view,
    //   then "control+click+drag" the element to the view controller, a 
    //   prompt opens and we choose the type of element needed
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordButton: UIButton!
    
    // MARK: AVAudioRecorder
    
    // create our AVAudioRecorder instance
    // - this gives us the object that has the ability to record audio and
    //   save it as a file ... with the URL property, can we save our file
    //   to a remote location like S3 buckets?
    var audioRecorder: AVAudioRecorder!
    
    // MARK: RecordingState
    
    // lets us know if we're recording or not
    enum RecordingState { case recording, notRecording }
    
    // MARK: ViewController lifecycle methods
    
    // the following are methods (callbacks) that represent the various 
    // states of our view controller (UIViewController Lifecycle):
    // 1. viewDidLoad
    // 2. viewWillAppear
    // 3. viewDidAppear
    // 4. viewWillDisappear
    // 5. viewDidDisappear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(.notRecording)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: button action methods

    // when record button is clicked, we do the following:
    // 1. set appropriate properties for our buttons and
    //    labels
    // 2. get the path to where we save our audio file
    //    via NSSearchPathForDirectoriesInDomains
    // 3. set the default name for our audio file
    // 4. put together the path and audio file name
    // 5. get our AVAudioSession session and set
    //    the mode and audio component
    // 6. create an instance of AVAudioRecorder with
    //    the path of our audio file
    // 7. set the AVAudioRecorder's delegate to this
    //    object so we can override methods:
    //    - audioRecorderDidFinishingRecording
    //    - audioRecorderEncodeErrorDidOccur
    // 8. set recording settings and start recording
    
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(.recording)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    // when stop button is clicked, we do the following:
    // 1. set appropriate properties for our buttons and
    //    labels
    // 2. stop the recording
    // 3. retrieve the audio session and de-activate it
    
    @IBAction func stopRecordingAudio(_ sender: Any) {
        configureUI(.notRecording)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: AVAudioRecorderDelegate methods
    
    // we're providing the definition of our AVAudioRecorderDelegate protocol methods
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            showAlert(Alerts.AudioEngineError, message: Alerts.RecordingFailedMessage)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        showAlert(Alerts.AudioEngineError, message: String(describing: error))
    }
    
    // MARK: prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    // MARK: configureUI
    
    // sets the label's text value, and enables/disables recordButton 
    // and stopRecordButton
    
    func configureUI(_ recordState: RecordingState) {
        switch recordState {
        case .recording:
            recordingLabel.text = "Recording in progress"
            stopRecordButton.isEnabled = true
            recordButton.isEnabled = false
        default:
            recordingLabel.text = "Tap to record"
            stopRecordButton.isEnabled = false
            recordButton.isEnabled = true
        }
    }
    
    // MARK: showAlert
    
    // lifted this from playsoundsviewcontroller-audio file to display 
    // messages to our user
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

