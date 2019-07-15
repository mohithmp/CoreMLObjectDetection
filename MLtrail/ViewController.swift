//
//  ViewController.swift
//  MLtrail
//
//  Created by Mohith Mullaguru Prabhakar on 7/13/19.
//  Copyright © 2019 Mohith Mullaguru Prabhakar. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // here is where we start camera
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video)
            else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice)
            else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self , queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        //let request = VNCoreMLRequest(model: VNCoreMLModel,
          //                            completionHandler: VNRequestCompletionHandler?)
        //VNImageRequestHandler(CGImage: CGImage, options: [:].perform(request: [VNREquest]))
        
        }
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
       // print("Camera was able to capture a frame:", Date())
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                else {return}
            
            // Here is where trainied ML Model goes
            guard let model = try? VNCoreMLModel(for: Resnet50().model)
                else { return }
            let request = VNCoreMLRequest(model: model)
            {
                (finishedReq, err) in
                
                // Perhaps check err
                
                //print(finishedReq.results)
                
                guard let results = finishedReq.results as?
                    [VNClassificationObservation] else {return}
                
                guard let firstObservation = results.first else
                { return }
                
               
                print(firstObservation.identifier, firstObservation.confidence)
                
            }
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}

