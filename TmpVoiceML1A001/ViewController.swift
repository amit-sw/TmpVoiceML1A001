//
//  ViewController.swift
//  TmpVoiceML1A001
//
//  Created by Amit Gupta on 11/10/20.
//

//
//  ViewController.swift
//  Currency_1
//
//  Created by admin on 11/9/20.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var belowView: UIView!
    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    
    var model = CatsAndDogsV001_1().model
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //camera
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        //the camera is now created
        
        
        view.addSubview(belowView)
        
        belowView.clipsToBounds = true
        belowView.layer.cornerRadius = 15.0
        belowView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

 
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection : AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: model) else { return }
        let request = VNCoreMLRequest(model: model) {
            (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            var name: String = firstObservation.identifier
            var acc: Int = Int(firstObservation.confidence * 100)
            
            DispatchQueue.main.async{
                self.objectName.text = name
                self.accuracyLabel.text = "Accuracy: \(acc)%"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @IBAction func voiceButton(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: objectName.text ?? "One Dollar")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        //utterance.rate = 0.1
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
}
